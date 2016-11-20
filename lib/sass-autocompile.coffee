{CompositeDisposable} = require('atom')

SassAutocompileOptions = require('./options')
SassAutocompileView = require('./sass-autocompile-view')
NodeSassCompiler = require('./compiler')

File = require('./helper/file')


module.exports =

    config:

        # General settings

        compileOnSave:
            title: 'Compile on Save'
            description: 'This option en-/disables auto compiling on save'
            type: 'boolean'
            default: true
            order: 10

        compileFiles:
            title: 'Compile files ...'
            description: 'Choose which SASS files you want this package to compile'
            type: 'string'
            enum: ['Only with first-line-comment', 'Every SASS file']
            default: 'Every SASS file'
            order: 11

        compilePartials:
            title: 'Compile Partials'
            description: 'Controls compilation of Partials (underscore as first character in filename) if there is no first-line-comment'
            type: 'boolean'
            default: false
            order: 12

        checkOutputFileAlreadyExists:
            title: 'Ask for overwriting already existent files'
            description: 'If target file already exists, sass-autocompile will ask you before overwriting'
            type: 'boolean'
            default: false
            order: 13

        directlyJumpToError:
            title: 'Directly jump to error'
            description: 'If enabled and you compile an erroneous SASS file, this file is opened and jumped to the problematic position.'
            type: 'boolean'
            default: false
            order: 14

        showCompileSassItemInTreeViewContextMenu:
            title: 'Show \'Compile SASS\' item in Tree View context menu'
            description: 'If enabled, Tree View context menu contains a \'Compile SASS\' item that allows you to compile that file via context menu'
            type: 'string'
            type: 'boolean'
            default: true
            order: 15


        # node-sass options

        compileCompressed:
            title: 'Compile with \'compressed\' output style'
            description: 'If enabled SASS files are compiled with \'compressed\' output style. Please define a corresponding output filename pattern or use inline parameter \'compressedFilenamePattern\''
            type: 'boolean'
            default: true
            order: 30

        compressedFilenamePattern:
            title: 'Filename pattern for \'compressed\' compiled files'
            description: 'Define the replacement pattern for compiled filenames with \'compressed\' output style. Placeholders are: \'$1\' for basename of file and \'$2\' for original file extension.'
            type: 'string'
            default: '$1.min.css'
            order: 31

        compileCompact:
            title: 'Compile with \'compact\' output style'
            description: 'If enabled SASS files are compiled with \'compact\' output style. Please define a corresponding output filename pattern or use inline parameter \'compactFilenamePattern\''
            type: 'boolean'
            default: false
            order: 32

        compactFilenamePattern:
            title: 'Filename pattern for \'compact\' compiled files'
            description: 'Define the replacement pattern for compiled filenames with \'compact\' output style. Placeholders are: \'$1\' for basename of file and \'$2\' for original file extension.'
            type: 'string'
            default: '$1.compact.css'
            order: 33

        compileNested:
            title: 'Compile with \'nested\' output style'
            description: 'If enabled SASS files are compiled with \'nested\' output style. Please define a corresponding output filename pattern or use inline parameter \'nestedFilenamePattern\''
            type: 'boolean'
            default: false
            order: 34

        nestedFilenamePattern:
            title: 'Filename pattern for \'nested\' compiled files'
            description: 'Define the replacement pattern for compiled filenames with \'nested\' output style. Placeholders are: \'$1\' for basename of file and \'$2\' for original file extension.'
            type: 'string'
            default: '$1.nested.css'
            order: 35

        compileExpanded:
            title: 'Compile with \'expanded\' output style'
            description: 'If enabled SASS files are compiled with \'expanded\' output style. Please define a corresponding output filename pattern or use inline parameter \'expandedFilenamePattern\''
            type: 'boolean'
            default: false
            order: 36

        expandedFilenamePattern:
            title: 'Filename pattern for \'expanded\' compiled files'
            description: 'Define the replacement pattern for compiled filenames with \'expanded\' output style. Placeholders are: \'$1\' for basename of file and \'$2\' for original file extension.'
            type: 'string'
            default: '$1.css'
            order: 37

        indentType:
            title: 'Indent type'
            description: 'Indent type for output CSS'
            type: 'string'
            enum: ['Space', 'Tab']
            default: 'Space'
            order: 38

        indentWidth:
            title: 'Indent width'
            description: 'Indent width; number of spaces or tabs'
            type: 'integer'
            enum: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            default: 2
            minimum: 0
            maximum: 10
            order: 39

        linefeed:
            title: 'Linefeed'
            description: 'Used to determine whether to use \'cr\', \'crlf\', \'lf\' or \'lfcr\' sequence for line break'
            type: 'string'
            enum: ['cr', 'crlf', 'lf', 'lfcr']
            default: 'lf'
            order: 40

        sourceMap:
            title: 'Build source map'
            description: 'If enabled a source map is generated'
            type: 'boolean'
            default: false
            order: 41

        sourceMapEmbed:
            title: 'Embed source map'
            description: 'If enabled source map is embedded as a data URI'
            type: 'boolean'
            default: false
            order: 42

        sourceMapContents:
            title: 'Include contents in source map information'
            description: 'If enabled contents are included in source map information'
            type: 'boolean'
            default: false
            order: 43

        sourceComments:
            title: 'Include additional debugging information in the output CSS file'
            description: 'If enabled additional debugging information are added to the output file as CSS comments. If CSS is compressed this feature is disabled by SASS compiler'
            type: 'boolean'
            default: false
            order: 44

        includePath:
            title: 'Include paths'
            description: 'Paths to look for imported files (@import declarations); comma separated, each path surrounded by quotes'
            type: 'string'
            default: ''
            order: 45

        precision:
            title: 'Precision'
            description: 'Used to determine how many digits after the decimal will be allowed. For instance, if you had a decimal number of 1.23456789 and a precision of 5, the result will be 1.23457 in the final CSS'
            type: 'integer'
            default: 5
            minimum: 0
            order: 46

        importer:
            title: 'Filename to custom importer'
            description: 'Path to .js file containing custom importer'
            type: 'string'
            default: ''
            order: 47

        functions:
            title: 'Filename to custom functions'
            description: 'Path to .js file containing custom functions'
            type: 'string'
            default: ''
            order: 48


        # Notification options

        notifications:
            title: 'Notification type'
            description: 'Select which types of notifications you wish to see'
            type: 'string'
            enum: ['Panel', 'Notifications', 'Panel, Notifications']
            default: 'Panel'
            order: 60

        autoHidePanel:
            title: 'Automatically hide panel on ...'
            description: 'Select on which event the panel should automatically disappear'
            type: 'string'
            enum: ['Never', 'Success', 'Error', 'Success, Error']
            default: 'Success'
            order: 61

        autoHidePanelDelay:
            title: 'Panel-auto-hide delay'
            description: 'Delay after which panel is automatically hidden'
            type: 'integer'
            default: 3000
            order: 62

        autoHideNotifications:
            title: 'Automatically hide notifications on ...'
            description: 'Select which types of notifications should automatically disappear'
            type: 'string'
            enum: ['Never', 'Info, Success', 'Error', 'Info, Success, Error']
            default: 'Info, Success'
            order: 63

        showStartCompilingNotification:
            title: 'Show \'Start Compiling\' Notification'
            description: 'If enabled a \'Start Compiling\' notification is shown'
            type: 'boolean'
            default: false
            order: 64

        showAdditionalCompilationInfo:
            title: 'Show additional compilation info'
            description: 'If enabled additiona infos like duration or file size is presented'
            type: 'boolean'
            default: true
            order: 65

        showNodeSassOutput:
            title: 'Show node-sass output after compilation'
            description: 'If enabled detailed output of node-sass command is shown in a new tab so you can analyse output'
            type: 'boolean'
            default: false
            order: 66

        showOldParametersWarning:
            title: 'Show warning when using old paramters'
            description: 'If enabled any time you compile a SASS file und you use old inline paramters, an warning will be occur not to use them'
            type: 'boolean'
            default: true
            order: 66


        # Advanced options

        nodeSassTimeout:
            title: '\'node-sass\' execution timeout'
            description: 'Maximal execution time of \'node-sass\''
            type: 'integer'
            default: 10000
            order: 80

        nodeSassPath:
            title: 'Path to \'node-sass\' command'
            description: 'Absolute path where \'node-sass\' executable is placed. Please read documentation before usage!'
            type: 'string'
            default: ''
            order: 81


    sassAutocompileView: null
    mainSubmenu: null
    contextMenuItem: null


    activate: (state) ->
        @subscriptions = new CompositeDisposable
        @editorSubscriptions = new CompositeDisposable

        @sassAutocompileView = new SassAutocompileView(new SassAutocompileOptions(), state.sassAutocompileViewState)
        @isProcessing = false


        # Deprecated option -- Remove in later version!!!
        if SassAutocompileOptions.get('enabled')
            SassAutocompileOptions.set('compileOnSave', SassAutocompileOptions.get('enabled'))
            SassAutocompileOptions.unset('enabled')
        if SassAutocompileOptions.get('outputStyle')
            SassAutocompileOptions.unset('outputStyle')
        if SassAutocompileOptions.get('macOsNodeSassPath')
            SassAutocompileOptions.set('nodeSassPath', SassAutocompileOptions.get('macOsNodeSassPath'))
            SassAutocompileOptions.unset('macOsNodeSassPath')


        @registerCommands()
        @registerTextEditorSaveCallback()
        @registerConfigObserver()
        @registerContextMenuItem()


    deactivate: () ->
        @subscriptions.dispose()
        @editorSubscriptions.dispose()
        @sassAutocompileView.destroy()


    serialize: () ->
        sassAutocompileViewState: @sassAutocompileView.serialize()


    registerCommands: () ->
        @subscriptions.add atom.commands.add 'atom-workspace',
            'sass-autocompile:compile-to-file': (evt) =>
                @compileToFile(evt)

            'sass-autocompile:compile-direct': (evt) =>
                @compileDirect(evt)

            'sass-autocompile:toggle-compile-on-save': =>
                @toggleCompileOnSave()

            'sass-autocompile:toggle-output-style-nested': =>
                @toggleOutputStyle('Nested')

            'sass-autocompile:toggle-output-style-compact': =>
                @toggleOutputStyle('Compact')

            'sass-autocompile:toggle-output-style-expanded': =>
                @toggleOutputStyle('Expanded')

            'sass-autocompile:toggle-output-style-compressed': =>
                @toggleOutputStyle('Compressed')

            'sass-autocompile:compile-every-sass-file': =>
                @selectCompileFileType('every')

            'sass-autocompile:compile-only-with-first-line-comment': =>
                @selectCompileFileType('first-line-comment')

            'sass-autocompile:toggle-check-output-file-already-exists': =>
                @toggleCheckOutputFileAlreadyExists()

            'sass-autocompile:toggle-directly-jump-to-error': =>
                @toggleDirectlyJumpToError()

            'sass-autocompile:toggle-show-compile-sass-item-in-tree-view-context-menu': =>
                @toggleShowCompileSassItemInTreeViewContextMenu()

            'sass-autocompile:close-message-panel': (evt) =>
                @closePanel()
                evt.abortKeyBinding()


    compileToFile: (evt) ->
        filename = undefined
        if evt.target.nodeName.toLowerCase() is 'atom-text-editor' or evt.target.nodeName.toLowerCase() is 'input'
            activeEditor = atom.workspace.getActiveTextEditor()
            if activeEditor
                filename = activeEditor.getURI()
        else
            target = evt.target
            if evt.target.nodeName.toLowerCase() is 'span'
                target= evt.target.parentNode
            isFileItem = target.getAttribute('class').split(' ').indexOf('file') >= 0
            if isFileItem
                filename = target.firstElementChild.getAttribute('data-path')

        if @isSassFile(filename)
            @compile(NodeSassCompiler.MODE_FILE, filename, false)


    compileDirect: (evt) ->
        return unless atom.workspace.getActiveTextEditor()
        @compile(NodeSassCompiler.MODE_DIRECT)


    toggleCompileOnSave: () ->
        SassAutocompileOptions.set('compileOnSave', !SassAutocompileOptions.get('compileOnSave'))
        if SassAutocompileOptions.get('compileOnSave')
            atom.notifications.addInfo 'SASS-AutoCompile: Enabled compile on save'
        else
            atom.notifications.addWarning 'SASS-AutoCompile: Disabled compile on save'
        @updateMenuItems()


    toggleOutputStyle: (outputStyle) ->
        switch outputStyle.toLowerCase()
            when 'compressed' then SassAutocompileOptions.set('compileCompressed', !SassAutocompileOptions.get('compileCompressed'))
            when 'compact' then SassAutocompileOptions.set('compileCompact', !SassAutocompileOptions.get('compileCompact'))
            when 'nested' then SassAutocompileOptions.set('compileNested', !SassAutocompileOptions.get('compileNested'))
            when 'expanded' then SassAutocompileOptions.set('compileExpanded', !SassAutocompileOptions.get('compileExpanded'))
        @updateMenuItems()


    selectCompileFileType: (type) ->
        if type is 'every'
            SassAutocompileOptions.set('compileFiles', 'Every SASS file')
        else if type is 'first-line-comment'
            SassAutocompileOptions.set('compileFiles', 'Only with first-line-comment')

        @updateMenuItems()


    toggleCheckOutputFileAlreadyExists: () ->
        SassAutocompileOptions.set('checkOutputFileAlreadyExists', !SassAutocompileOptions.get('checkOutputFileAlreadyExists'))
        @updateMenuItems()


    toggleDirectlyJumpToError: () ->
        SassAutocompileOptions.set('directlyJumpToError', !SassAutocompileOptions.get('directlyJumpToError'))
        @updateMenuItems()


    toggleShowCompileSassItemInTreeViewContextMenu: () ->
        SassAutocompileOptions.set('showCompileSassItemInTreeViewContextMenu', !SassAutocompileOptions.get('showCompileSassItemInTreeViewContextMenu'))
        @updateMenuItems()


    compile: (mode, filename = null, minifyOnSave = false) ->
        if @isProcessing
            return

        options = new SassAutocompileOptions()
        @isProcessing = true

        @sassAutocompileView.updateOptions(options)
        @sassAutocompileView.hidePanel(false, true)

        @compiler = new NodeSassCompiler(options)
        @compiler.onStart (args) =>
            @sassAutocompileView.startCompilation(args)

        @compiler.onWarning (args) =>
            @sassAutocompileView.warning(args)

        @compiler.onSuccess (args) =>
            @sassAutocompileView.successfullCompilation(args)

        @compiler.onError (args) =>
            @sassAutocompileView.erroneousCompilation(args)

        @compiler.onFinished (args) =>
            @sassAutocompileView.finished(args)
            @isProcessing = false
            @compiler.destroy()
            @compiler = null

        @compiler.compile(mode, filename, minifyOnSave)


    registerTextEditorSaveCallback: () ->
        @editorSubscriptions.add atom.workspace.observeTextEditors (editor) =>
            @subscriptions.add editor.onDidSave =>
                if !@isProcessing and editor and editor.getURI and @isSassFile(editor.getURI())
                   @compile(NodeSassCompiler.MODE_FILE, editor.getURI(), true)


    isSassFile: (filename) ->
        return File.hasFileExtension(filename, ['.scss', '.sass'])


    registerConfigObserver: () ->
        @subscriptions.add atom.config.observe SassAutocompileOptions.OPTIONS_PREFIX + 'compileOnSave', (newValue) =>
            @updateMenuItems()
        @subscriptions.add atom.config.observe SassAutocompileOptions.OPTIONS_PREFIX + 'compileFiles', (newValue) =>
            @updateMenuItems()
        @subscriptions.add atom.config.observe SassAutocompileOptions.OPTIONS_PREFIX + 'checkOutputFileAlreadyExists', (newValue) =>
            @updateMenuItems()
        @subscriptions.add atom.config.observe SassAutocompileOptions.OPTIONS_PREFIX + 'directlyJumpToError', (newValue) =>
            @updateMenuItems()
        @subscriptions.add atom.config.observe SassAutocompileOptions.OPTIONS_PREFIX + 'showCompileSassItemInTreeViewContextMenu', (newValue) =>
            @updateMenuItems()

        @subscriptions.add atom.config.observe SassAutocompileOptions.OPTIONS_PREFIX + 'compileCompressed', (newValue) =>
            @updateMenuItems()
        @subscriptions.add atom.config.observe SassAutocompileOptions.OPTIONS_PREFIX + 'compileCompact', (newValue) =>
            @updateMenuItems()
        @subscriptions.add atom.config.observe SassAutocompileOptions.OPTIONS_PREFIX + 'compileNested', (newValue) =>
            @updateMenuItems()
        @subscriptions.add atom.config.observe SassAutocompileOptions.OPTIONS_PREFIX + 'compileExpanded', (newValue) =>
            @updateMenuItems()


    registerContextMenuItem: () ->
        menuItem = @getContextMenuItem()
        menuItem.shouldDisplay = (evt) =>
            showItemOption = SassAutocompileOptions.get('showCompileSassItemInTreeViewContextMenu')
            if showItemOption
                target = evt.target
                if target.nodeName.toLowerCase() is 'span'
                    target = target.parentNode

                isFileItem = target.getAttribute('class').split(' ').indexOf('file') >= 0
                if isFileItem
                    child = target.firstElementChild
                    filename = child.getAttribute('data-name')
                    return @isSassFile(filename)

            return false


    updateMenuItems: ->
        menu = @getMainMenuSubmenu().submenu
        return unless menu

        menu[3].label = (if SassAutocompileOptions.get('compileOnSave') then '✔' else '✕') + '  Compile on Save'
        menu[4].label = (if SassAutocompileOptions.get('checkOutputFileAlreadyExists') then '✔' else '✕') + '  Check output file already exists'
        menu[5].label = (if SassAutocompileOptions.get('directlyJumpToError') then '✔' else '✕') + '  Directly jump to error'
        menu[6].label = (if SassAutocompileOptions.get('showCompileSassItemInTreeViewContextMenu') then '✔' else '✕') + '  Show \'Compile SASS\' item in tree view context menu'

        compileFileMenu = menu[8].submenu
        if compileFileMenu
            compileFileMenu[0].checked = SassAutocompileOptions.get('compileFiles') is 'Every SASS file'
            compileFileMenu[1].checked = SassAutocompileOptions.get('compileFiles') is 'Only with first-line-comment'

        outputStylesMenu = menu[9].submenu
        if outputStylesMenu
            outputStylesMenu[0].label = (if SassAutocompileOptions.get('compileCompressed') then '✔' else '✕') + '  Compressed'
            outputStylesMenu[1].label = (if SassAutocompileOptions.get('compileCompact') then '✔' else '✕') + '  Compact'
            outputStylesMenu[2].label = (if SassAutocompileOptions.get('compileNested') then '✔' else '✕') + '  Nested'
            outputStylesMenu[3].label = (if SassAutocompileOptions.get('compileExpanded') then '✔' else '✕') + '  Expanded'

        atom.menu.update()


    getMainMenuSubmenu: ->
        if @mainSubmenu is null
            found = false
            for menu in atom.menu.template
                if menu.label is 'Packages' || menu.label is '&Packages'
                    found = true
                    for submenu in menu.submenu
                        if submenu.label is 'SASS Autocompile'
                            @mainSubmenu = submenu
                            break
                if found
                    break
        return @mainSubmenu


    getContextMenuItem: ->
        if @contextMenuItem is null
            found = false
            for items in atom.contextMenu.itemSets
                if items.selector is '.tree-view'
                    for item in items.items
                        if item.id is 'sass-autocompile-context-menu-compile'
                            found = true
                            @contextMenuItem = item
                            break

                if found
                    break
        return @contextMenuItem


    closePanel: () ->
        @sassAutocompileView.hidePanel()
