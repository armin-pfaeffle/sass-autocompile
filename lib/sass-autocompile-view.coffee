{$$, View} = require 'atom-space-pen-views'

module.exports =
class SassAutocompileView extends View

    @content: ->
        @div class: 'sass-autocompile atom-panel panel-bottom hide', =>
            @div class: 'inset-panel', =>
                @div outlet: 'panelHeading', class: 'panel-heading no-border', =>
                    @span
                        outlet: 'panelHeaderCaption'
                        class: 'header-caption'
                        'SASS AutoCompile: Compiling...'
                    @span
                        outlet: 'panelLoading'
                        class: 'inline-block loading loading-spinner-tiny hide'
                    @span
                        outlet: 'panelOpenNodeSassOutput'
                        class: 'open-node-sass-output hide'
                        click: 'openNodeSassOutput'
                        'Show detailed output'
                    @div class: 'inline-block pull-right', =>
                        @button
                            outlet: 'panelClose'
                            class: 'btn btn-close hide'
                            click: 'hidePanel'
                            'Close'
                @div outlet: 'panelBody', class: 'panel-body padded hide', =>


    @OPTIONS_PREFIX = 'sass-autocompile.'


    @getOption: (name) ->
        return atom.config.get(SassAutocompileView.OPTIONS_PREFIX + name)


    @setOption: (name, value) ->
        atom.config.set(SassAutocompileView.OPTIONS_PREFIX + name, value)


    @unsetOption: (name) ->
        atom.config.unset(SassAutocompileView.OPTIONS_PREFIX + name)


    initialize: (serializeState) ->
        @inProgress = false
        @timeout = null

        atom.workspace.observeTextEditors (editor) =>
            editor.onDidSave =>
                if !@inProgress
                    @compile editor


    # Tear down any state and detach
    destroy: ->
        @detach()


    prepareOptions: ->
        @options =
            enabled: SassAutocompileView.getOption('enabled')

            compress: SassAutocompileView.getOption('compress')
            sourceMap: SassAutocompileView.getOption('sourceMap')
            sourceMapEmbed: SassAutocompileView.getOption('sourceMapEmbed')
            sourceMapContents: SassAutocompileView.getOption('sourceMapContents')
            sourceComments: SassAutocompileView.getOption('sourceComments')
            includePath: SassAutocompileView.getOption('includePath')

            showInfoNotification: SassAutocompileView.getOption('notifications') in ['Notifications', 'Panel, Notifications']
            showSuccessNotification: SassAutocompileView.getOption('notifications') in ['Notifications', 'Panel, Notifications']
            showErrorNotification: SassAutocompileView.getOption('notifications') in ['Notifications', 'Panel, Notifications']

            autoHideInfoNotification: SassAutocompileView.getOption('autoHideNotifications') in ['Info, Success', 'Info, Success, Error']
            autoHideSuccessNotification: SassAutocompileView.getOption('autoHideNotifications') in ['Info, Success', 'Info, Success, Error']
            autoHideErrorNotification: SassAutocompileView.getOption('autoHideNotifications') in ['Error', 'Info, Success, Error']

            showPanel: SassAutocompileView.getOption('notifications') in ['Panel', 'Panel, Notifications']

            autoHidePanelOnSuccess: SassAutocompileView.getOption('autoHidePanel') in ['Success', 'Success, Error']
            autoHidePanelOnError: SassAutocompileView.getOption('autoHidePanel') in ['Error', 'Success, Error']
            autoHidePanelDelay: SassAutocompileView.getOption('autoHidePanelDelay')

            showStartCompilingNotification: SassAutocompileView.getOption('showStartCompilingNotification')

            showNodeSassOutput : SassAutocompileView.getOption('showNodeSassOutput')

            macOsNodeSassPath: SassAutocompileView.getOption('macOsNodeSassPath')


    compile: (editor) ->
        path = require 'path'

        activeEditor = atom.workspace.getActiveTextEditor()
        if activeEditor and activeEditor.getURI
            filename = activeEditor.getURI()
            fileExtension = path.extname filename

            if ['.scss', '.sass'].indexOf(fileExtension.toLowerCase()) >= 0
                @compileSass filename


    getParams: (filename, callback) ->
        fs = require 'fs'
        path = require 'path'
        readline = require 'readline'

        params =
            file: filename
            out: null
            main: null
            compress: null
            sourceMap: null
            sourceMapEmbed: null
            sourceMapContents: null
            sourceComments: null
            includePath: null

        parse = (firstLine) =>
            firstLine.split(',').forEach (item) ->
                i = item.indexOf ':'

                if i < 0
                    return

                key = item.substr(0, i).trim()
                match = /^\s*\/\/\s*(.+)/.exec(key);

                if match
                    key = match[1]

                value = item.substr(i + 1).trim()
                if value.toLowerCase() in [true, 1, 'true', 'yes', 'y', '1']
                    value = true
                else if value.toLowerCase() in [false, 0, 'false', 'no', 'n', '0']
                    value = false

                params[key] = value

            if params.main isnt null
                parentFilename = path.resolve(path.dirname(filename), params.main)
                @getParams parentFilename, callback
            else
                callback params

        if !fs.existsSync filename
            @showErrorNotification 'Path does not exist:', "#{filename}", true
            @inProgress = false
            return null

        # Read and parse first line
        rl = readline.createInterface
            input: fs.createReadStream filename
            output: process.stdout
            terminal: false

        firstLine = null
        rl.on 'line', (line) ->
            if firstLine is null
                firstLine = line
                parse firstLine


    compileSass: (filename) ->
        @prepareOptions()
        @nodeSassOutput = null
        if !@options.enabled
            return

        path = require('path')
        exec = require('child_process').exec

        compile = (params) =>
            if params.out is null
                return

            params.cssFilename = path.resolve(path.dirname(params.file), params.out)

            @startCompiling(params.file)
            try
                execParameters = @obtainExecParameters(params)
                exec execParameters.command, { env: execParameters.environment }, (error, stdout, stderr) =>
                    @nodeSassOutput = if stdout then stdout else stderr
                    if error != null
                        if error.message.indexOf('"message":') > -1
                            errorJson = error.message.match(/{\n(.*?(\n))+}/gm);
                            error = JSON.parse(errorJson)
                        else
                            error = error.message

                        @endCompiling false, error
                    else
                        @endCompiling true, params.cssFilename, params.compress
            catch e
                errorMessage = "#{e.message} - index: #{e.index}, line: #{e.line}, file: #{e.filename}"
                @endCompiling false, errorMessage

        @getParams filename, (params) ->
            if params isnt null
                compile params


    obtainExecParameters: (params) ->
        # Build command string
        nodeSassParameters = @buildNodeSassParameters(params)
        command = 'node-sass ' + nodeSassParameters.join(' ')

        # Clone current environment
        environment = Object.create(process.env)

        # If it's Mac OS we have to add macOsNodeSassPath to command and to environment variable
        # PATH so shell AND node.js can find node-sass command
        if process.platform is "darwin"
            path = require('path')
            command = path.join(@options.macOsNodeSassPath, command)
            environment.PATH += ":#{@options.macOsNodeSassPath}"

        return {
            command: command,
            environment: environment
        }


    buildNodeSassParameters: (params) ->
        path = require('path')

        execParameters = []

        # --output-style
        execParameters.push('--output-style ' + (if params.compress or (params.compress is null and @options.compress) then 'compressed' else 'nested'))

        # --source-comments
        if params.sourceComments or (params.sourceComments is null and @options.sourceComments)
            execParameters.push('--source-comments')

        # --source-map
        if (params.sourceMap isnt null and !!params.sourceMap) or (params.sourceMap is null and @options.sourceMap)
            if params.sourceMap or (params.sourceMap is null and @options.sourceMap)
                sourceMapFilename = params.cssFilename + '.map'
            else
                sourceMapFilename = path.resolve(path.dirname(params.file), params.sourceMap)
            execParameters.push('--source-map "' + sourceMapFilename + '"')

        # --source-map-embed
        if params.sourceMapEmbed or (params.sourceMapEmbed is null and @options.sourceMapEmbed)
            execParameters.push('--source-map-embed')

        # --source-map-contents
        if params.sourceMapContents or (params.sourceMapContents is null and @options.sourceMapContents)
            execParameters.push('--source-map-contents')

        # --include-path
        if !!params.includePath
            execParameters.push('--include-path "' + params.includePath + '"')
        else if !!@options.includePath
            execParameters.push('--include-path "' + @options.includePath + '"')

        # CSS target and output file
        execParameters.push('"' + params.file + '"')
        execParameters.push('"' + params.cssFilename + '"')

        return execParameters


    showInfoNotification: (title, message, forceShow = false) ->
        if !@options.showInfoNotification and !forceShow
            return

        atom.notifications.addInfo title,
            detail: message
            dismissable: !@options.autoHideInfoNotification


    showSuccessNotification: (title, message, forceShow = false) ->
        if !@options.showSuccessNotification and !forceShow
            return

        atom.notifications.addSuccess title,
            detail: message
            dismissable: !@options.autoHideSuccessNotification


    showErrorNotification: (title, message, forceShow = false) ->
        if !@options.showErrorNotification and !forceShow
            return

        atom.notifications.addError title,
            detail: message
            dismissable: !@options.autoHideErrorNotification


    startCompiling: (filename) ->
        @inProgress = true

        if @options.showStartCompilingNotification
            @showInfoNotification 'Start compiling:', filename

        if @options.showPanel
            @showPanel()
            @setPanelCaption 'SASS AutoCompile: Compiling...'
            if @options.showStartCompilingNotification
                @setPanelMessage filename, 'terminal'


    endCompiling: (wasSuccessful, message, compressed) ->
        if wasSuccessful
            notificationMessage = message + (if compressed then ' (compressed)' else '')
            @showSuccessNotification 'Successfully compiled to:', notificationMessage

            if @options.showPanel
                @setPanelCaption 'SASS AutoCompile: Successfully compiled'
                @setSuccessMessageToPanel message, compressed
                @showCloseButton()
                if @options.autoHidePanelOnSuccess
                    @hidePanel true
        else
            if typeof message == 'object'
                errorNotification = "FILE:\n" + message.file + "\n \nERROR:\n" + message.message + "\n \nLINE:    " + message.line + "\nCOLUMN:  " + message.column
            else
                errorNotification = message
            @showErrorNotification 'Error while compiling:', errorNotification

            if @options.showPanel
                @setPanelCaption 'SASS AutoCompile: Error while compiling'
                @setErrorMessageToPanel message
                @showCloseButton()
                if @options.autoHidePanelOnError
                    @hidePanel true

        if @nodeSassOutput
            @panelOpenNodeSassOutput.removeClass('hide')
        if @options.showNodeSassOutput
            @openNodeSassOutput()

        @inProgress = false


    setPanelCaption: (caption) ->
        @panelHeaderCaption.html caption


    setPanelMessage: (message, icon = "chevron-right") ->
        icon = if icon then 'icon-' + icon else ''
        @panelBody.removeClass('hide').append $$ ->
            @p =>
                @span class: "icon #{icon} text-info", message


    setSuccessMessageToPanel: (filename, compressed) ->
        @panelBody.removeClass('hide').append $$ ->
            @p class: 'open-css-file', =>
                @span class: "icon icon-check text-success", filename
                @span class: "compressed",  (if compressed then ' (compressed)' else '')

        @find('.open-css-file').on 'click', (event) =>
            @openFile filename


    setErrorMessageToPanel: (error) ->
        if typeof error == 'object'
            @panelBody.removeClass('hide').append $$ ->
                @div class: 'open-error-file', =>
                    @p class: "icon icon-alert text-error", =>
                        @span class: "error-caption", 'Error:'
                        @span class: "error-text", error.message
                    @p class: 'error-details', =>
                        @span class: 'error-file', error.file
                        @span class: 'error-line', error.line
                        @span class: 'error-column', error.column

            @find('.open-error-file').on 'click', (event) =>
                @openFile error.file, error.line, error.column
        else
            @panelBody.removeClass('hide').append $$ ->
                @p class: "icon icon-alert text-error", =>
                    @span class: "error-caption", 'Error:'
                    @span class: "error-text", error


    openFile: (filename, line, column) ->
        atom.workspace.open filename,
            initialLine: if line then line - 1 else 0,
            initialColumn: if column then column - 1 else 0


    showPanel: ->
        @inProgress = true

        clearTimeout(@timeout)

        @panelHeading.addClass('no-border')
        @panelBody.addClass('hide').empty()
        @panelLoading.removeClass('hide')
        @panelOpenNodeSassOutput.addClass('hide')
        @panelClose.addClass('hide')

        if @panel
            @panel.destroy()
        @panel = atom.workspace.addBottomPanel
            item: this

        @removeClass 'hide'


    hidePanel: (withDelay = false) ->
        @panelLoading.addClass('hide')
        @panelOpenNodeSassOutput.addClass('hide')

        clearTimeout @timeout

        if withDelay == true
            @timeout = setTimeout =>
                @addClass 'hide'
            , @options.autoHidePanelDelay
        else
            @addClass 'hide'


    showCloseButton: ->
        @panelLoading.addClass('hide')
        @panelClose.removeClass('hide')


    openNodeSassOutput: ->
        if @nodeSassOutput
            if not @nodeSassOutputEditor
                atom.workspace.open().then (editor) =>
                    @nodeSassOutputEditor = editor
                    editor.setText(@nodeSassOutput)
                    editor.onDidSave =>
                        @nodeSassOutputEditor = null
                    editor.onDidDestroy =>
                        @nodeSassOutputEditor = null
            else
                pane = atom.workspace.paneForItem(@nodeSassOutputEditor)
                pane.activateItem(@nodeSassOutputEditor)
