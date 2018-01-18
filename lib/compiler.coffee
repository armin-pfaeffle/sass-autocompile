{Emitter} = require('event-kit')
SassAutocompileOptions = require('./options')

InlineParameterParser = require('./helper/inline-parameters-parser')
File = require('./helper/file')
ArgumentParser = require('./helper/argument-parser')

fs = require('fs')
path = require('path')
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


    compile: (mode, filename = null, compileOnSave = false) ->
        @compileOnSave = compileOnSave
        @childFiles = {}
        @_compile(mode, filename)


    # If filename is null then active text editor is used for compilation
    _compile: (mode, filename = null, compileOnSave = false) ->
        @mode = mode
        @targetFilename = filename
        @inputFile = undefined
        @outputFile = undefined

        # Parse inline parameters and run compilation; for better performance we use active
        # text-editor if possible, so parameter parser must not load file again
        parameterParser = new InlineParameterParser()
        parameterTarget = @getParameterTarget()
        parameterParser.parse parameterTarget, (params, error) =>
            # If package is called by save-event of editor, but compilation is prohibited by
            # options or first line parameter, execution is cancelled
            if @compileOnSave and @prohibitCompilationOnSave(params)
                @emitFinished()
                return

            # Check if there is a first line paramter
            if params is false and @options.compileOnlyFirstLineCommentFiles
                @emitFinished()
                return

            # A potenial parsing error is only handled if compilation is executed and that's the
            # case if compiler is executed by command or after compile on save, so this code must
            # be placed above the code before
            if error
                @emitMessageAndFinish('error', error, true)
                return

            @setupInputFile(filename)
            if (errorMessage = @validateInputFile()) isnt undefined
                @emitMessageAndFinish('error', errorMessage, true)
                return

            # If there is NO first-line-comment, so no main file is referenced, we should check
            # is user wants to compile Partials
            if params is false and @isPartial() and not @options.compilePartials
                @emitFinished()
                return

            # In case there is a "main" inline paramter, params is a string and contains the
            # target filename.
            # It's important to check that inputFile.path is not params because of infinite loop
            if typeof params.main is 'string'
                if params.main is @inputFile.path or @childFiles[params.main] isnt undefined
                    @emitMessageAndFinish('error', 'Following the main parameter ends in a loop.')
                else if @inputFile.isTemporary
                    @emitMessageAndFinish('error', '\'main\' inline parameter is not supported in direct compilation.')
                else
                    @childFiles[params.main] = true
                    @_compile(@mode, params.main)
            else
                @emitStart()

                if @isCompileToFile() and not @ensureFileIsSaved()
                    @emitMessageAndFinish('warning', 'Compilation cancelled')
                    return

                @updateOptionsWithInlineParameters(params)
                @outputStyles = @getOutputStylesToCompileTo()

                if @outputStyles.length is 0
                    @emitMessageAndFinish('warning', 'No output style defined! Please enable at least one style in options or use inline parameters.')
                    return

                @doCompile()


    getParameterTarget: () ->
        if typeof @targetFilename is 'string'
            return @targetFilename
        else
            return atom.workspace.getActiveTextEditor()


    prohibitCompilationOnSave: (params) ->
        if params and params.compileOnSave in [true, false]
            @options.compileOnSave = params.compileOnSave
        return not @options.compileOnSave


    isPartial: () ->
        filename = path.basename(@inputFile.path)
        return (filename[0] == '_')


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
                    @inputFile.path = File.getTemporaryFilename('sass-autocompile.input.', null, syntax)
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
            message: "Is the syntax of your input SASS or SCSS?"
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


    validateInputFile: () ->
        errorMessage = undefined

        # If no inputFile.path is given, then we cannot compile the file or content,
        # because something is wrong
        if not @inputFile.path
            errorMessage = 'Invalid file: ' + @inputFile.path

        if not fs.existsSync(@inputFile.path)
            errorMessage = 'File does not exist: ' + @inputFile.path

        return errorMessage


    ensureFileIsSaved: () ->
        editors = atom.workspace.getTextEditors()
        for editor in editors
            if editor and editor.getURI and editor.getURI() is @inputFile.path and editor.isModified()
                filename = path.basename(@inputFile.path)
                dialogResultButton = atom.confirm
                    message: "'#{filename}' has changes, do you want to save them?"
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
                @emitMessage('warning', 'Please don\'t use \'out\', \'outputStyle\' or \'compress\' parameter any more. Have a look at the documentation for newer parameters')

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
        if (typeof params.includePath is 'string' and params.includePath.length > 1) or Array.isArray(params.includePath)
            @options.includePath = params.includePath
        else if (typeof params.includePaths is 'string' and params.includePaths.length > 1) or Array.isArray(params.includePaths)
            @options.includePath = params.includePaths

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
            outputFile.path = File.getTemporaryFilename('sass-autocompile.output.', null, 'css')
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

            if not path.isAbsolute(path.dirname(filename))
                outputPath = path.dirname(@inputFile.path)
                filename = path.join(outputPath, filename)

            outputFile.path = filename

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
            File.ensureDirectoryExists(outputPath)


    tryToFindNodeSassInstallation: (callback) ->
        # Command which checks if node-sass is accessable without absolute path
        # This command works on Windows, Linux and Mac OS
        devNull = if process.platform is 'win32' then 'nul' else '/dev/null'
        existanceCheckCommand = "node-sass --version >#{devNull} 2>&1 && (echo found) || (echo fail)"

        possibleNodeSassPaths = ['']
        if typeof @options.nodeSassPath is 'string' and @options.nodeSassPath.length > 1
            possibleNodeSassPaths.push(@options.nodeSassPath)
        if process.platform is 'win32'
            possibleNodeSassPaths.push( path.join(process.env[ if process.platform is 'win32' then 'USERPROFILE' else 'HOME' ], 'AppData\\Roaming\\npm') )
        if process.platform is 'linux'
            possibleNodeSassPaths.push('/usr/local/bin')
        if process.platform is 'darwin'
            possibleNodeSassPaths.push('/usr/local/bin')


        checkNodeSassExists = (foundInPath) =>
            if typeof foundInPath is 'string'
                if foundInPath is @options.nodeSassPath
                    callback(true, false)
                else if @askAndFixNodeSassPath(foundInPath)
                    callback(true, true)
                else
                    callback(false, false)
                return

            if possibleNodeSassPaths.length is 0
                # NOT found and NOT fixed
                callback(false, false)
                return

            searchPath = possibleNodeSassPaths.shift()
            command = path.join(searchPath, existanceCheckCommand)
            environment = JSON.parse(JSON.stringify( process.env ));
            if typeof searchPath is 'string' and searchPath.length > 1
                environment.PATH += ":#{searchPath}"

            exec command, { env: environment }, (error, stdout, stderr) =>
                if stdout.trim() is 'found'
                    checkNodeSassExists(searchPath)
                else
                    checkNodeSassExists()


        # Start recursive search for node-sass command
        checkNodeSassExists()


    askAndFixNodeSassPath: (nodeSassPath) ->
        if nodeSassPath is '' and @options.nodeSassPath isnt ''
            detailedMessage = "'Path to node-sass command' option will be cleared, because node-sass is accessable without absolute path."

        else if nodeSassPath isnt '' and @options.nodeSassPath is ''
            detailedMessage = "'Path to node-sass command' option will be set to '#{nodeSassPath}', because command was found there."

        else if nodeSassPath isnt '' and @options.nodeSassPath isnt ''
            detailedMessage = "'Path to node-sass command' option will be replaced with '#{nodeSassPath}', because command was found there."

        # Ask user to fix that path
        dialogResultButton = atom.confirm
            message: "'node-sass' command could not be found with current configuration, but it can be automatically fixed. Fix it?"
            detailedMessage: detailedMessage
            buttons: ["Fix it", "Cancel"]
        switch dialogResultButton
            when 0
                SassAutocompileOptions.set('nodeSassPath', nodeSassPath)
                @options.nodeSassPath = nodeSassPath
                return true
            when 1
                return false


    doCompile: () ->
        if @outputStyles.length is 0
            @emitFinished()
            if @inputFile.isTemporary
                File.delete(@inputFile.path)
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
            timeout = if @options.nodeSassTimeout > 0 then @options.nodeSassTimeout else 0
            child = exec execParameters.command, { env: execParameters.environment, timeout: timeout }, (error, stdout, stderr) =>
                # exitCode is 1 when something went wrong with executing node-sass command, not when
                # there is an error in SASS
                if child.exitCode > 0
                    @tryToFindNodeSassInstallation (found, fixed) =>
                        # Only retry to compile if node-sass command could be fixed, not if
                        # node-sass could be found. Because there can be other erros than only
                        # a non-findable node-sass
                        if fixed
                            @_compile(@mode, @targetFilename)
                            # try again compiling
                        else
                            # throw error
                            @onCompiled(outputFile, error, stdout, stderr, child.killed)
                            @doCompile() # <--- Recursion!!!
                else
                    @onCompiled(outputFile, error, stdout, stderr, child.killed)
                    @doCompile() # <--- Recursion!!!

        catch error
            emitterParameters.message = error
            @emitter.emit('error', emitterParameters)

            # Clear output styles, so no further compilation will be executed
            @outputStyles = [];

            @doCompile() # <--- Recursion!!!


    onCompiled: (outputFile, error, stdout, stderr, killed) ->
        emitterParameters = @getBasicEmitterParameters({ outputFilename: outputFile.path, outputStyle: outputFile.style })
        statistics =
            duration: new Date().getTime() - @startCompilingTimestamp

        try
            # Save node-sass compilation output (info, warnings, errors, etc.)
            emitterParameters.nodeSassOutput = if stdout then stdout else stderr

            if error isnt null or killed
                if killed
                    # node-sass has been executed too long
                    errorMessage = "Compilation cancelled because of timeout (#{@options.nodeSassTimeout} ms)"

                else
                    # error while executing node-sass
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
                statistics.before = File.getFileSize(@inputFile.path)
                statistics.after = File.getFileSize(outputFile.path)
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
                File.delete(outputFile.path)


    prepareExecParameters: (outputFile) ->
        # Build the command string
        nodeSassParameters = @buildNodeSassParameters(outputFile)
        command = 'node-sass ' + nodeSassParameters.join(' ')

        # Clone current environment, so do not touch the global one but can modify the settings
        environment = JSON.parse(JSON.stringify( process.env ));

        # Because of permission problems in Mac OS and Linux we sometimes need to add nodeSassPath
        # to command and to environment variable PATH so shell AND node.js can find node-sass
        # executable
        if typeof @options.nodeSassPath is 'string' and @options.nodeSassPath.length > 1
            # TODO: Hier sollte es so optimiert werden, dass wenn der absolute Pfad die Anwendung enthält diese übernommen werden sollte
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
            if typeof includePath is 'string'
                argumentParser = new ArgumentParser()
                includePath = argumentParser.parseValue('[' + includePath + ']')
                if !Array.isArray(includePath)
                    includePath = [includePath]

            for i in [0 .. includePath.length - 1]
                if not path.isAbsolute(includePath[i])
                    includePath[i] = path.join(workingDirectory, includePath[i])

                # Remove trailing (back-)slash, because else there seems to be a bug in node-sass
                # so compiling ends in an infinite loop
                if includePath[i].substr(-1) is path.sep
                    includePath[i] = includePath[i].substr(0, includePath[i].length - 1)

                execParameters.push('--include-path "' + includePath[i] + '"')

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


    emitStart: () ->
        @emitter.emit('start', @getBasicEmitterParameters())


    emitFinished: () ->
        @deleteTemporaryFiles()
        @emitter.emit('finished', @getBasicEmitterParameters())


    emitMessage: (type, message) ->
        @emitter.emit(type, @getBasicEmitterParameters({ message: message }))


    emitMessageAndFinish: (type, message, emitStartEvent = false) ->
        if emitStartEvent
            @emitStart()
        @emitMessage(type, message)
        @emitFinished()


    getBasicEmitterParameters: (additionalParameters = {}) ->
        parameters =
            isCompileToFile: @isCompileToFile(),
            isCompileDirect: @isCompileDirect(),

        if @inputFile
            parameters.inputFilename = @inputFile.path

        for key, value of additionalParameters
            parameters[key] = value

        return parameters


    deleteTemporaryFiles: ->
        if @inputFile and @inputFile.isTemporary
            File.delete(@inputFile.path)
        if @outputFile and @outputFile.isTemporary
            File.delete(@outputFile.path)


    isCompileDirect: ->
        return @mode is NodeSassCompiler.MODE_DIRECT


    isCompileToFile: ->
        return @mode is NodeSassCompiler.MODE_FILE


    onStart: (callback) ->
        @emitter.on 'start', callback


    onSuccess: (callback) ->
        @emitter.on 'success', callback


    onWarning: (callback) ->
        @emitter.on 'warning', callback


    onError: (callback) ->
        @emitter.on 'error', callback


    onFinished: (callback) ->
        @emitter.on 'finished', callback
