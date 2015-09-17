SassAutocompileView = require './sass-autocompile-view'

module.exports =

    config:

        # General settings

        enabled:
            title: 'Enabled'
            description: 'This option en-/disables auto compiling on save.'
            type: 'boolean'
            default: true
            order: 10


        # node-sass options

        outputStyle:
            title: 'Output style'
            description: 'Choose the output style of the CSS'
            type: 'string'
            default: 'Nested'
            enum: ['Nested', 'Compact', 'Expanded', 'Compressed']
            order: 30

        indentType:
            title: 'Indent type'
            description: 'Indent type for output CSS'
            type: 'string'
            default: 'Space'
            enum: ['Space', 'Tab']
            order: 31

        indentWidth:
            title: 'Indent width'
            description: 'Indent width; number of spaces or tabs'
            type: 'integer'
            default: 2
            minimum: 0
            maximum: 10
            enum: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            order: 32

        linefeed:
            title: 'Linefeed'
            description: 'Used to determine whether to use \'cr\', \'crlf\', \'lf\' or \'lfcr\' sequence for line break'
            type: 'string'
            default: 'lf'
            enum: ['cr', 'crlf', 'lf', 'lfcr']
            order: 33

        sourceMap:
            title: 'Build source map'
            description: 'If enabled a source map is generated'
            type: 'boolean'
            default: false
            order: 34

        sourceMapEmbed:
            title: 'Embed source map'
            description: 'If enabled source map is embedded as a data URI'
            type: 'boolean'
            default: false
            order: 35

        sourceMapContents:
            title: 'Include contents in source map information'
            description: 'If enabled contents are included in source map information'
            type: 'boolean'
            default: false
            order: 36

        sourceComments:
            title: 'Include additional debugging information in the output CSS file'
            description: 'If enabled additional debugging information are added to the output file as CSS comments. If CSS is compressed this feature is disabled by SASS compiler'
            type: 'boolean'
            default: false
            order: 37

        includePath:
            title: 'Include path'
            description: 'Path to look for imported files (@import declarations)'
            type: 'string'
            default: ''
            order: 38

        precision:
            title: 'Precision'
            description: 'Used to determine how many digits after the decimal will be allowed. For instance, if you had a decimal number of 1.23456789 and a precision of 5, the result will be 1.23457 in the final CSS'
            type: 'integer'
            default: 5
            minimum: 0
            order: 39

        importer:
            title: 'Filename to custom importer'
            description: 'Path to .js file containing custom importer'
            type: 'string'
            default: ''
            order: 40

        functions:
            title: 'Filename to custom functions'
            description: 'Path to .js file containing custom functions'
            type: 'string'
            default: ''
            order: 41


        # Notification options

        notifications:
            title: 'Notifications'
            description: 'Select which types of notifications you wish to see'
            type: 'string'
            default: 'Panel'
            enum: ['Panel', 'Notifications', 'Panel, Notifications']
            order: 60

        autoHidePanel:
            title: 'Automatically hide panel on ...'
            description: 'Select on which event the panel should automatically disappear'
            type: 'string'
            default: 'Success'
            enum: ['Never', 'Success', 'Error', 'Success, Error']
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
            default: 'Info, Success'
            enum: ['Never', 'Info, Success', 'Error', 'Info, Success, Error']
            order: 63

        showStartCompilingNotification:
            title: 'Show \'Start Compiling\' Notification'
            description: 'If enabled a \'Start Compiling\' notification is shown'
            type: 'boolean'
            default: false
            order: 64

        showNodeSassOutput:
            title: 'Show node-sass output after compilation'
            description: 'If enabled detailed output of node-sass command is shown in a new tab so you can analyse output'
            type: 'boolean'
            default: false
            order: 65

        macOsNodeSassPath:
            title: 'Absolute path where \'node-sass\' resides (might fix \'node-sass not found\' issues)'
            description: 'Absolute path where \'node-sass\' command can be found'
            type: 'string'
            default: '/usr/local/bin'
            order: 66


    sassAutocompileView: null


    activate: (state) ->
        @sassAutocompileView = new SassAutocompileView(state.sassAutocompileViewState)

        if not SassAutocompileView.getOption('outputStyle')
            if SassAutocompileView.getOption('compress')
                SassAutocompileView.getOption('outputStyle', 'Compressed')
            else
                SassAutocompileView.getOption('outputStyle', 'Nested')

        atom.commands.add 'atom-workspace',
            'sass-autocompile:toggle-enabled': =>
                @toggleEnabled()

            'sass-autocompile:toggle-always-compress': =>
                @toggleCompress()

            'sass-autocompile:select-output-style-nested': =>
                @selectOutputStyle('Nested')

            'sass-autocompile:select-output-style-compact': =>
                @selectOutputStyle('Compact')

            'sass-autocompile:select-output-style-expanded': =>
                @selectOutputStyle('Expanded')

            'sass-autocompile:select-output-style-compressed': =>
                @selectOutputStyle('Compressed')

            'sass-autocompile:close-message-panel': (e) =>
                @closeMessagePanel()
                e.abortKeyBinding()

        @registerConfigObserver()


    deactivate: ->
        @sassAutocompileView.destroy()


    serialize: ->
        sassAutocompileViewState: @sassAutocompileView.serialize()


    toggleEnabled: ->
        SassAutocompileView.setOption('enabled', !SassAutocompileView.getOption('enabled'))
        if SassAutocompileView.getOption 'enabled'
            atom.notifications.addInfo 'SASS-AutoCompile: Enabled auto-compilation'
        else
            atom.notifications.addWarning 'SASS-AutoCompile: Disabled auto-compilation'
        @updateMenuItems()


    selectOutputStyle: (outputStyle) ->
        SassAutocompileView.setOption('outputStyle', outputStyle)
        @updateMenuItems()


    registerConfigObserver: ->
        atom.config.observe SassAutocompileView.OPTIONS_PREFIX + 'outputStyle', (newValue) =>
            @updateMenuItems()


    updateMenuItems: ->
        for menu in atom.menu.template
            if menu.label == 'Packages' || menu.label == '&Packages'
                for packagesSubenu in menu.submenu
                    if packagesSubenu.label == 'SASS Autocompile'
                        toggleEnabledItem = packagesSubenu.submenu[0]
                        toggleEnabledItem.label = (if SassAutocompileView.getOption('enabled') then 'Disable' else 'Enable')

                        outputStyleSubmenu = packagesSubenu.submenu[1]
                        for outputStyleItem in outputStyleSubmenu.submenu
                            outputStyleItem.checked = outputStyleItem.label.toLowerCase() is SassAutocompileView.getOption('outputStyle').toLowerCase()

        atom.menu.update()


    closeMessagePanel: ->
        @sassAutocompileView.hidePanel()
