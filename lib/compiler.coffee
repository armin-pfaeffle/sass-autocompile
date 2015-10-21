{Emitter} = require('event-kit')
SassAutocompileOptions = require('./options')
SassAutocompileInlineParameters = require('./inline-parameters')

fs = require('fs')
path = require('path')
file = require('./file')
exec = require('child_process').exec


module.exports =
class NodeSassCompiler

    @MODE_DIRECT = 'direct'
    @MODE_FILE = 'to-file'


    constructor: (options) ->
        @options = options
        @emitter = new Emitter()


    destroy: () ->
        @emitter.dispose()
        @emitter = null


    # If filename is null then active text editor is used for compilation
    compile: (mode, filename = null) ->
        @mode = mode
        @setupInputFile(filename)

        # If no inputFile.path is given, then we cannot compile the file or content, because something
        # is wrong
        if not @inputFile.path
            @throwMessageAndFinish('error', 'Invalid file: ' + @inputFile.path)

        # Check file existance
        else if not fs.existsSync(@inputFile.path)
            @throwMessageAndFinish('error', 'File does not exist: ' + @inputFile.path)

        else
            # Parse inline parameters
            parameters = new SassAutocompileInlineParameters()
            parameters.parse @inputFile.path, (params, error) =>
                if error
                    @throwMessageAndFinish('error', error)

                # Check if there is a first line paramter
                if params is false and @options.compileOnlyFirstLineCommentFiles
                    @emitter.emit('finished', @getBasicEmitterParameters())
                    return

                # In case there is a "main" inline paramter, params is a string and contains the
                # target filename.
                # It's important to check that inputFile.path is not params because of infinite loop
                else if typeof params is 'string' and params isnt @inputFile.path
                    if @inputFile.isTemporary
                        @throwMessageAndFinish('error', '\'main\' inline parameter is not supported in direct compilation.')
                    else
                        @compile(@mode, params)
                else
                    if @isCompileToFile() and not @ensureFileIsSaved()
                        @emit.emit('finished', @getBasicEmitterParameters())
                        return

                    @emitter.emit('start', @getBasicEmitterParameters())

                    @updateOptionsWithInlineParameters(params)
                    @outputStyles = @getOutputStylesToCompileTo()

                    if @outputStyles.length is 0
                        @throwMessageAndFinish('warning', 'No output style defined! Please enable at least one style in options or use inline parameters.')

                    # Start recursive compilation
                    @doCompile()


    setupInputFile: (filename = null) ->
        @inputFile =
            isTemporary: false

        if filename
            @inputFile.path = filename
        else
            activeEditor = atom.workspace.getActiveTextEditor()
            return unless activeEditor

            if @isCompileDirect()
                syntax = @askForInputSyntax()
                if syntax
                    @inputFile.path = file.getTemporaryFilename('sass-autocompile.input.', null, syntax)
                    @inputFile.isTemporary = true
                    fs.writeFileSync(@inputFile.path, activeEditor.getText())
                else
                    @inputFile.path = undefined
            else
                @inputFile.path = activeEditor.getURI()
                if not @inputFile.path
                    @inputFile.path = @askForSavingUnsavedFileInActiveEditor()

    askForInputSyntax: () ->
        dialogResultButton = atom.confirm
            message: "Is the syntax if your inout SASS or SCSS?"
            buttons: ['SASS', 'SCSS', 'Cancel']
        switch dialogResultButton
            when 0 then syntax = 'sass'
            when 1 then syntax = 'scss'
            else syntax = undefined
        return syntax


    askForSavingUnsavedFileInActiveEditor: () ->
        activeEditor = atom.workspace.getActiveTextEditor()
        dialogResultButton = atom.confirm
            message: "In order to compile this SASS file to a CSS file, you have do save it before. Do you want to save this file?"
            detailedMessage: "Alternativly you can use 'Direct Compilation' for compiling without creating a CSS file."
            buttons: ["Save", "Cancel"]
        if dialogResultButton is 0
            filename = atom.showSaveDialogSync()
            try
                activeEditor.saveAs(filename)
            catch error
                # do nothing if something fails because getURI() will return undefined, if
                # file is not saved

            filename = activeEditor.getURI()
            return filename

        return undefined


    ensureFileIsSaved: () ->
        editors = atom.workspace.getTextEditors()
        for editor in editors
            if editor and editor.getURI and editor.getURI() is @inputFile.path and editor.isModified()
                dialogResultButton = atom.confirm
                    message: "'#{editor.getTitle()}' has changes, do you want to save them?"
                    detailedMessage: "In order to compile SASS you have to save changes."
                    buttons: ["Save and compile", "Cancel"]
                if dialogResultButton is 0
                    editor.save()
                    break
                else
                    return false

        return true


    # Available parameters
    #   out
    #   outputStyle
    #
    #   compileCompressed
    #   compressedFilenamePattern
    #   compileCompact
    #   compactFilenamePattern
    #   compileNested
    #   nestedFilenamePattern
    #   compileExpanded
    #   expandedFilenamePattern
    #
    #   indentType
    #   indentWidth
    #   linefeed
    #   sourceMap
    #   sourceMapEmbed
    #   sourceMapContents
    #   sourceComments
    #   includePath
    #   precision
    #   importer
    #   functions
    updateOptionsWithInlineParameters: (params) ->
        # BACKWARD COMPATIBILITY: params.out and param.outputStyle
        # Should we let this code here, so we can decide to output only one single file with one output style per SASS file?
        if typeof params.out is 'string' or typeof params.outputStyle is 'string' or typeof params.compress is 'boolean'

            if @options.showOldParametersWarning
                emitterParameters = @getBasicEmitterParameters({ message: 'Please don\'t use \'out\', \'outputStyle\' or \'compress\' parameter any more. Have a look at the documentation for newer parameters' })
                @emitter.emit('warning', emitterParameters)

            # Set default output style
            outputStyle = 'compressed'

            # If "compress" is set, apply this value
            if params.compress is false
                outputStyle = 'nested'
            if params.compress is true
                outputStyle = 'compressed'

            if params.outputStyle
                outputStyle = if typeof params.outputStyle is 'string' then params.outputStyle.toLowerCase() else 'compressed'

            @options.compileCompressed = (outputStyle is 'compressed')
            if outputStyle is 'compressed' and typeof params.out is 'string' and params.out.length > 0
                @options.compressedFilenamePattern = params.out

            @options.compileCompact = (outputStyle is 'compact')
            if outputStyle is 'compact' and typeof params.out is 'string' and params.out.length > 0
                @options.compactFilenamePattern = params.out

            @options.compileNested = (outputStyle is 'nested')
            if outputStyle is 'nested' and typeof params.out is 'string' and params.out.length > 0
                @options.nestedFilenamePattern = params.out

            @options.compileExpanded = (outputStyle is 'expanded')
            if outputStyle is 'expanded' and typeof params.out is 'string' and params.out.length > 0
                @options.expandedFilenamePattern = params.out


        # If user specifies a single or multiple output styles, we reset the default settings
        # so only the given output styles are compiled to
        if params.compileCompressed or params.compileCompact or params.compileNested or params.compileExpanded
            @options.compileCompressed = false
            @options.compileCompact = false
            @options.compileNested = false
            @options.compileExpanded = false

        # compileCompressed
        if params.compileCompressed is true or params.compileCompressed is false
            @options.compileCompressed = params.compileCompressed
        else if typeof params.compileCompressed is 'string'
            @options.compileCompressed = true
            @options.compressedFilenamePattern = params.compileCompressed

        # compressedFilenamePattern
        if typeof params.compressedFilenamePattern is 'string' and params.compressedFilenamePattern.length > 1
            @options.compressedFilenamePattern = params.compressedFilenamePattern

        # compileCompact
        if params.compileCompact is true or params.compileCompact is false
            @options.compileCompact = params.compileCompact
        else if typeof params.compileCompact is 'string'
            @options.compileCompact = true
            @options.compactFilenamePattern = params.compileCompact

        # compactFilenamePattern
        if typeof params.compactFilenamePattern is 'string' and params.compactFilenamePattern.length > 1
            @options.compactFilenamePattern = params.compactFilenamePattern

        # compileNested
        if params.compileNested is true or params.compileNested is false
            @options.compileNested = params.compileNested
        else if typeof params.compileNested is 'string'
            @options.compileNested = true
            @options.nestedFilenamePattern = params.compileNested

        # nestedFilenamePattern
        if typeof params.nestedFilenamePattern is 'string' and params.nestedFilenamePattern.length > 1
            @options.nestedFilenamePattern = params.nestedFilenamePattern

        # compileExpanded
        if params.compileExpanded is true or params.compileExpanded is false
            @options.compileExpanded = params.compileExpanded
        else if typeof params.compileExpanded is 'string'
            @options.compileExpanded = true
            @options.expandedFilenamePattern = params.compileExpanded

        # expandedFilenamePattern
        if typeof params.expandedFilenamePattern is 'string' and params.expandedFilenamePattern.length > 1
            @options.expandedFilenamePattern = params.expandedFilenamePattern

        # indentType
        if typeof params.indentType is 'string'  and params.indentType.toLowerCase() in ['space', 'tab']
            @options.indentType = params.indentType.toLowerCase()

        # indentWidth
        if typeof params.indentWidth is 'number' and params.indentWidth <= 10 and indentWidth >= 0
            @options.indentWidth = params.indentWidth

        # linefeed
        if typeof params.linefeed is 'string' and params.linefeed.toLowerCase() in ['cr', 'crlf', 'lf', 'lfcr']
            @options.linefeed = params.linefeed.toLowerCase()

        # sourceMap
        if params.sourceMap is true or params.sourceMap is false or (typeof params.sourceMap is 'string' and params.sourceMap.length > 1)
            @options.sourceMap = params.sourceMap

        # sourceMapEmbed
        if params.sourceMapEmbed is true or params.sourceMapEmbed is false
            @options.sourceMapEmbed = params.sourceMapEmbed

        # sourceMapContents
        if params.sourceMapContents is true or params.sourceMapContents is false
            @options.sourceMapContents = params.sourceMapContents

        # sourceComments
        if params.sourceComments is true or params.sourceComments is false
            @options.sourceComments = params.sourceComments

        # includePath
        if typeof params.includePath is 'string' and params.includePath.length > 1
            @options.includePath = params.includePath

        # precision
        if typeof params.precision is 'number' and params.precision >= 0
            @options.precision = params.precision

        # importer
        if typeof params.importer is 'string' and params.importer.length > 1
            @options.importer = params.importer

        # functions
        if typeof params.functions is 'string' and params.functions.length > 1
            @options.functions = params.functions


    getOutputStylesToCompileTo: () ->
        outputStyles = []
        if @options.compileCompressed
            outputStyles.push('compressed')
        if @options.compileCompact
            outputStyles.push('compact')
        if @options.compileNested
            outputStyles.push('nested')
        if @options.compileExpanded
            outputStyles.push('expanded')

        # When it's direct compilation use has to select a single output style if there is more
        # than one output style available
        if @isCompileDirect() and outputStyles.length > 1
            outputStyles.push('Cancel')
            dialogResultButton = atom.confirm
                message: "For direction compilation you have to select a single output style. Which one do you want to use?"
                buttons: outputStyles
            if dialogResultButton < outputStyles.length - 1
                # Return only the selected output style as array
                outputStyles = [ outputStyles[dialogResultButton] ]
            else
                # Returning an empty array means no compilation is started
                outputStyles = []

        return outputStyles


    getOutputFile: (outputStyle) ->
        outputFile =
            style: outputStyle
            isTemporary: false

        if @isCompileDirect()
            outputFile.path = file.getTemporaryFilename('sass-autocompile.output.', null, 'css')
            outputFile.isTemporary = true
        else
            switch outputFile.style
                when 'compressed' then pattern = @options.compressedFilenamePattern
                when 'compact' then pattern = @options.compactFilenamePattern
                when 'nested' then pattern = @options.nestedFilenamePattern
                when 'expanded' then pattern = @options.expandedFilenamePattern
                else throw new Error('Invalid output style.')

            basename = path.basename(@inputFile.path)
            # we need the file extension without the dot!
            fileExtension = path.extname(basename).replace('.', '')

            filename = basename.replace(new RegExp('^(.*?)\.(' + fileExtension + ')$', 'gi'), pattern)

            outputPath = path.dirname(@inputFile.path)
            if @options.outputPath
                if path.isAbsolute(@options.outputPath)
                    outputPath = @options.outputPath
                else
                    outputPath = path.join(outputPath, @options.outputPath)

            outputFile.path = path.join(outputPath, filename)

        return outputFile


    checkOutputFileAlreadyExists: (outputFile) ->
        if @options.checkOutputFileAlreadyExists
            if fs.existsSync(outputFile.path)
                dialogResultButton = atom.confirm
                    message: "The output file already exists. Do you want to overwrite it?"
                    detailedMessage: "Output file: '#{outputFile.path}'"
                    buttons: ["Overwrite", "Skip", "Cancel"]
                switch dialogResultButton
                    when 0 then return 'overwrite'
                    when 1 then return 'skip'
                    when 2 then return 'cancel'
        return 'overwrite'


    ensureOutputDirectoryExists: (outputFile) ->
        if @isCompileToFile()
            outputPath = path.dirname(outputFile.path)
            file.ensureDirectoryExists(outputPath)


    doCompile: () ->
        if @outputStyles.length is 0
            @emitter.emit('finished', @getBasicEmitterParameters())
            if @inputFile.isTemporary
                file.delete(@inputFile.path)
            return

        outputStyle = @outputStyles.pop();
        outputFile = @getOutputFile(outputStyle)
        emitterParameters = @getBasicEmitterParameters({ outputFilename: outputFile.path, outputStyle: outputFile.style })

        try
            if @isCompileToFile()
                switch @checkOutputFileAlreadyExists(outputFile)
                    when 'overwrite' then # do nothing
                    when 'cancel' then throw new Error('Compilation cancelled')
                    when 'skip'
                        emitterParameters.message = 'Compilation skipped: ' + outputFile.path
                        @emitter.emit('warning', emitterParameters)
                        @doCompile() # <--- Recursion!!!
                        return

            @ensureOutputDirectoryExists(outputFile)

            @startCompilingTimestamp = new Date().getTime()

            execParameters = @prepareExecParameters(outputFile)
            exec execParameters.command, { env: execParameters.environment }, (error, stdout, stderr) =>
                @onCompiled(outputFile, error, stdout, stderr)
                @doCompile() # <--- Recursion!!!

        catch error
            emitterParameters.message = error
            @emitter.emit('error', emitterParameters)

            # Clear output styles, so no further compilation will be executed
            @outputStyles = [];

            @doCompile() # <--- Recursion!!!


    onCompiled: (outputFile, error, stdout, stderr) ->
        emitterParameters = @getBasicEmitterParameters({ outputFilename: outputFile.path, outputStyle: outputFile.style })
        statistics =
            duration: new Date().getTime() - @startCompilingTimestamp

        try
            # Save node-sass compilation output (info, warnings, errors, etc.)
            emitterParameters.nodeSassOutput = if stdout then stdout else stderr

            if error isnt null
                if error.message.indexOf('"message":') > -1
                    errorJson = error.message.match(/{\n(.*?(\n))+}/gm);
                    errorMessage = JSON.parse(errorJson)
                else
                    errorMessage = error.message

                emitterParameters.message = errorMessage
                @emitter.emit('error', emitterParameters)

                # Clear output styles, so no further compilation will be executed
                @outputStyles = [];
            else
                statistics.before = file.getFileSize(@inputFile.path)
                statistics.after = file.getFileSize(outputFile.path)
                statistics.unit = 'Byte'

                if @isCompileDirect()
                    compiledCss = fs.readFileSync(outputFile.path)
                    atom.workspace.getActiveTextEditor().setText( compiledCss.toString() )

                emitterParameters.statistics = statistics
                @emitter.emit('success', emitterParameters)

        finally
            # Delete temporary created output file, even if there was an error
            # But do not delete a temporary input file, because of multiple outputs!
            if outputFile.isTemporary
                file.delete(outputFile.path)


    prepareExecParameters: (outputFile) ->
        # Build the command string
        nodeSassParameters = @buildNodeSassParameters(outputFile)
        command = 'node-sass ' + nodeSassParameters.join(' ')

        # Clone current environment, so do not touch the global one but can modify the settings
        environment = Object.create(process.env)

        # Because of permission problems in Mac OS and Linux we sometimes need to add nodeSassPath
        # to command and to environment variable PATH so shell AND node.js can find node-sass
        # executable
        if typeof @options.nodeSassPath is 'string' and @options.nodeSassPath.length > 1
            command = path.join(@options.nodeSassPath, command)
            environment.PATH += ":#{@options.nodeSassPath}"

        return {
            command: command,
            environment: environment
        }


    buildNodeSassParameters: (outputFile) ->
        execParameters = []
        workingDirectory = path.dirname(@inputFile.path)

        # --output-style
        execParameters.push('--output-style ' + outputFile.style)

        # --indent-type
        if typeof @options.indentType is 'string' and @options.indentType.length > 0
            execParameters.push('--indent-type ' + @options.indentType.toLowerCase())

        # --indent-width
        if typeof @options.indentWidth is 'number'
            execParameters.push('--indent-width ' + @options.indentWidth)

        # --linefeed
        if typeof @options.linefeed is 'string' and @options.linefeed.lenght > 0
            execParameters.push('--linefeed ' + @options.linefeed)

        # --source-comments
        if @options.sourceComments is true
            execParameters.push('--source-comments')

        # --source-map
        if @options.sourceMap is true or (typeof @options.sourceMap is 'string' and @options.sourceMap.length > 0)
            if @options.sourceMap is true
                sourceMapFilename = outputFile.path + '.map'
            else
                basename = path.basename(outputFile.path)
                fileExtension = path.extname(basename).replace('.', '')
                sourceMapFilename = basename.replace(new RegExp('^(.*?)\.(' + fileExtension + ')$', 'gi'), @options.sourceMap)
            execParameters.push('--source-map "' + sourceMapFilename + '"')

        # --source-map-embed
        if @options.sourceMapEmbed is true
            execParameters.push('--source-map-embed')

        # --source-map-contents
        if @options.sourceMapContents is true
            execParameters.push('--source-map-contents')

        # --include-path
        if @options.includePath
            includePath = @options.includePath
            if not path.isAbsolute(includePath)
                includePath = path.join(workingDirectory, includePath)
            execParameters.push('--include-path "' + path.resolve(includePath) + '"')

        # --precision
        if typeof @options.precision is 'number'
            execParameters.push('--precision ' + @options.precision)

        # --importer
        if typeof @options.importer is 'string' and @options.importer.length > 0
            importerFilename = @options.importer
            if not path.isAbsolute(importerFilename)
                importerFilename = path.join(workingDirectory , importerFilename)
            execParameters.push('--importer "' + path.resolve(importerFilename) + '"')

        # --functions
        if typeof @options.functions is 'string' and @options.functions.length > 0
            functionsFilename = @options.functions
            if not path.isAbsolute(functionsFilename)
                functionsFilename = path.join(workingDirectory , functionsFilename)
            execParameters.push('--functions "' + path.resolve(functionsFilename) + '"')

        # CSS target and output file
        execParameters.push('"' + @inputFile.path + '"')
        execParameters.push('"' + outputFile.path + '"')

        return execParameters


    throwMessageAndFinish: (type, message) ->
        if @inputFile and @inputFile.isTemporary
            file.delete(@inputFile.path)
        if @outputFile and @outputFile.isTemporary
            file.delete(@outputFile.path)

        emitterParameters = @getBasicEmitterParameters({ message: message })
        @emitter.emit(type, emitterParameters)
        @emitter.emit('finished', @getBasicEmitterParameters())


    getBasicEmitterParameters: (additionalParameters = {}) ->
        parameters =
            isCompileToFile: @isCompileToFile(),
            isCompileDirect: @isCompileDirect(),
            inputFilename: @inputFile.path

        for key, value of additionalParameters
            parameters[key] = value

        return parameters



    isCompileDirect: ->
        return @mode is NodeSassCompiler.MODE_DIRECT


    isCompileToFile: ->
        return @mode is NodeSassCompiler.MODE_FILE


    onStart: (callback) ->
        @emitter.on 'start', callback


    onError: (callback) ->
        @emitter.on 'error', callback


    onSuccess: (callback) ->
        @emitter.on 'success', callback


    onFinished: (callback) ->
        @emitter.on 'finished', callback


    onWarning: (callback) ->
        @emitter.on 'warning', callback
