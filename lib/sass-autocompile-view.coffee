{View, $, $$} = require 'atom'

module.exports =
class SassAutocompileView extends View
    @content: ->
        @div class: 'sass-autocompile tool-panel panel-bottom hide', =>
            @div class: "inset-panel", =>
                @div class: "panel-heading no-border", =>
                    @span class: 'inline-block pull-right loading loading-spinner-tiny hide'
                    @span 'SASS AutoCompile'
                @div class: "panel-body padded hide"

    initialize: (serializeState) ->
        @inProgress = false
        @timeout = null

        @panelHeading = @find('.panel-heading')
        @panelBody = @find('.panel-body')
        @panelLoading = @find('.loading')

        atom.workspaceView.on 'core:save', (e) =>
            if !@inProgress
                @compile atom.workspace.activePaneItem

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
        @detach()

    compile: (editor) ->
        path = require 'path'

        filePath = editor.getUri()
        fileExt = path.extname filePath

        if fileExt == '.scss'
            @compileSass filePath

    getParams: (filePath, callback) ->
        fs = require 'fs'
        path = require 'path'
        readline = require 'readline'

        params =
            file: filePath
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
                @getParams path.resolve(path.dirname(filePath), params.main), callback
            else
                callback params

        if !fs.existsSync filePath
            atom.notifications.addError 'Path does not exist:',
                detail: "#{filePath}"
                dismissable: true

            @inProgress = false

            return null

        rl = readline.createInterface
            input: fs.createReadStream filePath
            output: process.stdout
            terminal: false

        firstLine = null

        rl.on 'line', (line) ->
            if firstLine is null
                firstLine = line
                parse firstLine

    compileSass: (filePath) ->
        fs = require 'fs'
        path = require 'path'
        exec = require('child_process').exec

        compile = (params) =>
            if params.out is false
                return

            outputStyle = if params.compress then 'compressed' else 'nested'
            newFile = path.resolve(path.dirname(params.file), params.out)
            newPath = path.dirname newFile

            try
                execString = 'node-sass --output-style ' + outputStyle + ' ' + params.file + ' ' + newFile
                exec execString, (error, stdout, stderr) =>
                    if error != null
                        atom.notifications.addError 'Error while compiling:',
                            detail: error.message
                            dismissable: true
                    else
                        atom.notifications.addSuccess 'Successfuly compiled: ' + newFile

                    @inProgress = false
                    return
            catch e
                atom.notifications.addError 'Error while compiling:',
                    detail: "#{e.message} - index: #{e.index}, line: #{e.line}, file: #{e.filename}"
                    dismissable: true

        @getParams filePath, (params) ->
            if params isnt null
                compile params
