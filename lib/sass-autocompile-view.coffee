{View, $, $$} = require 'atom'

module.exports =
class SassAutocompileView extends View

    @content: ->
        @div class: 'sass-autocompile atom-panel panel-bottom hide', =>
            @div class: "inset-panel", =>
                @div class: "panel-heading no-border", =>
                    @span
                        class: 'header-caption'
                        'SASS AutoCompile: Compiling...'
                    @span
                        class: 'inline-block loading loading-spinner-tiny hide'
                        style: 'margin-left: 10px;'
                    @div class: 'inline-block pull-right', =>
                        @button
                            class: 'btn btn-close hide'
                            click: 'hidePanel'
                            'Close'
                @div class: "panel-body padded hide", =>


    initialize: (serializeState) ->
        @inProgress = false
        @timeout = null

        @panelHeading = @find('.panel-heading')
        @panelHeaderCaption = @find('.header-caption')
        @panelBody = @find('.panel-body')
        @panelLoading = @find('.loading')
        @panelClose = @find('.btn-close')

        atom.workspace.observeTextEditors (editor) =>
            editor.onDidSave =>
                if !@inProgress
                    @prepareOptions()
                    @compile atom.workspace.activePaneItem

    # Returns an object that can be retrieved when package is activated
    serialize: ->


    # Tear down any state and detach
    destroy: ->
        @detach()


    prepareOptions: ->
        @options =
            enabled: atom.config.get('sass-autocompile.enabled')
            alwaysCompress: atom.config.get('sass-autocompile.alwaysCompress')

            showInfoNotification: atom.config.get('sass-autocompile.notifications') in ['Notifications', 'Panel, Notifications']
            showSuccessNotification: atom.config.get('sass-autocompile.notifications') in ['Notifications', 'Panel, Notifications']
            showErrorNotification: atom.config.get('sass-autocompile.notifications') in ['Notifications', 'Panel, Notifications']

            autoHideInfoNotification: atom.config.get('sass-autocompile.autoHideNotifications') in ['Info, Success', 'Info, Success, Error']
            autoHideSuccessNotification: atom.config.get('sass-autocompile.autoHideNotifications') in ['Info, Success', 'Info, Success, Error']
            autoHideErrorNotification: atom.config.get('sass-autocompile.autoHideNotifications') in ['Error', 'Info, Success, Error']

            showPanel: atom.config.get('sass-autocompile.notifications') in ['Panel', 'Panel, Notifications']

            autoHidePanelOnSuccess: atom.config.get('sass-autocompile.autoHidePanel') in ['Success', 'Success, Error']
            autoHidePanelOnError: atom.config.get('sass-autocompile.autoHidePanel') in ['Error', 'Success, Error']
            autoHidePanelDelay: atom.config.get('sass-autocompile.autoHidePanelDelay')

            showStartCompilingNotification: atom.config.get('sass-autocompile.showStartCompilingNotification')


    compile: (editor) ->
        if !@options.enabled
            return

        path = require 'path'

        filename = editor.getUri()
        fileExtension = path.extname filename

        if fileExtension == '.scss'
            @compileSass filename


    getParams: (filename, callback) ->
        fs = require 'fs'
        path = require 'path'
        readline = require 'readline'

        params =
            file: filename
            compress: false
            main: false
            out: false

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

                params[key] = value

            if params.main isnt false
                parentFilename = path.resolve(path.dirname(filename), params.main)
                @getParams parentFilename, callback
            else
                callback params

        if !fs.existsSync filename
            @showErrorNotification 'Path does not exist:', "#{filename}"
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
        path = require 'path'
        exec = require('child_process').exec

        compile = (params) =>
            if params.out is false
                return

            if @options.alwaysCompress
                params.compress = true

            outputStyle = if params.compress then 'compressed' else 'nested'
            cssFilename = path.resolve(path.dirname(params.file), params.out)

            @startCompiling params.file
            try
                execString = 'node-sass --output-style ' + outputStyle + ' ' + params.file + ' ' + cssFilename
                exec execString, (error, stdout, stderr) =>
                    if error != null
                        if error.message.indexOf('"message"') > -1
                            # Parse error
                            json = error.message.substr( error.message.indexOf('\n') + 1 )
                            error = JSON.parse json
                        else
                            error = error.message

                        @endCompiling false, error
                    else
                        @endCompiling true, cssFilename, params.compress

                    @inProgress = false
                    return
            catch e
                errorMessage = "#{e.message} - index: #{e.index}, line: #{e.line}, file: #{e.filename}"
                @endCompiling false, errorMessage

        @getParams filename, (params) ->
            if params isnt null
                compile params


    showInfoNotification: (title, message) ->
        atom.notifications.addInfo title,
            detail: message
            dismissable: !@options.autoHideInfoNotification


    showSuccessNotification: (title, message) ->
        atom.notifications.addSuccess title,
            detail: message
            dismissable: !@options.autoHideSuccessNotification


    showErrorNotification: (title, message) ->
        atom.notifications.addError title,
            detail: message
            dismissable: !@options.autoHideErrorNotification


    startCompiling: (filename) ->
        @inProgress = true

        if @options.showStartCompilingNotification and @options.showInfoNotification
            @showInfoNotification 'Start compiling:', filename

        if @options.showPanel
            @showPanel()
            @setPanelCaption 'SASS AutoCompile: Compiling...'
            @setPanelMessage filename, 'terminal'


    endCompiling: (wasSuccessful, message, compressed) ->
        if wasSuccessful
            if @options.showSuccessNotification
                notificationMessage = message + (if compressed then ' (compressed)' else '')
                @showSuccessNotification 'Successfuly compiled to:', notificationMessage

            if @options.showPanel
                @setPanelCaption 'SASS AutoCompile: Successfully compiled'
                @setSuccessMessageToPanel message, compressed
                @showCloseButton()
        else
            if @options.showErrorNotification
                if typeof message == 'object'
                    errorNotification = "FILE:\n" + message.file + "\n \nERROR:\n" + message.message + "\n \nLINE:    " + message.line + "\nCOLUMN:  " + message.column
                else
                    errorNotification = message
                @showErrorNotification 'Error while compiling:', errorNotification

            if @options.showPanel
                @setPanelCaption 'SASS AutoCompile: Error while compiling'
                @setErrorMessageToPanel message
                @showCloseButton()

        if @options.showPanel and @options.autoHidePanelOnSuccess
            @hidePanel true

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
        console.log 'openFile'
        atom.workspace.open filename,
            initialLine: if line then line - 1 else 0,
            initialColumn: if column then column - 1 else 0


    showPanel: ->
        @inProgress = true

        clearTimeout @timeout

        @panelHeading.addClass 'no-border'
        @panelBody.addClass('hide').empty()
        @panelLoading.removeClass 'hide'
        @panelClose.addClass 'hide'

        atom.workspace.addBottomPanel
            item: this

        @removeClass 'hide'


    hidePanel: (withTimeout) ->
        @panelLoading.addClass 'hide'

        clearTimeout @timeout

        if withTimeout
            @timeout = setTimeout =>
                @addClass 'hide'
            , @options.autoHidePanelDelay
        else
            @addClass 'hide'


    showCloseButton: ->
        @panelLoading.addClass 'hide'
        @panelClose.removeClass 'hide'
