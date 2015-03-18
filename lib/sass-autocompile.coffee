SassAutocompileView = require './sass-autocompile-view'

module.exports =

    config:
        enabled:
            title: 'Enabled'
            description: 'This option en-/disables auto compiling on save.'
            type: 'boolean'
            default: true
            order: 1

        alwaysCompress:
            title: 'Always Compress'
            description: 'If enabled this options overrides \'compress: true\' parameter.'
            type: 'boolean'
            default: false
            order: 2

        sourceMap:
            title: 'Build source map'
            description: 'If true a source map is generated. Overrides \'sourceMap: true\' parameter.'
            type: 'boolean'
            default: false
            order: 3

        sourceMapEmbed:
            title: 'Embed source map'
            description: 'If true source map is embedded as a data URI. Overrides \'sourceMapEmbed: true\' parameter.'
            type: 'boolean'
            default: false
            order: 4

        sourceMapContents:
            title: 'Include contents in source map information'
            description: 'If true contents are included in source map information. Overrides \'sourceMapContents: true\' parameter.'
            type: 'boolean'
            default: false
            order: 5

        sourceComments:
            title: 'Include contents in source map information'
            description: 'If true additional debugging information in the output file as CSS comments are enabled. If file is compressed this feature is disabled by SASS compiler. Overrides \'sourceComments: true\' parameter.'
            type: 'boolean'
            default: false
            order: 6

        includePath:
            title: 'Include path'
            description: 'Path to look for imported files (@import declarations). Overrides \'includePath\' parameter.'
            type: 'string'
            default: ''
            order: 7

        notifications:
            title: 'Notifications'
            description: 'Select which types of notifications you wish to see.'
            type: 'string'
            default: 'Panel'
            enum: ['Panel', 'Notifications', 'Panel, Notifications']
            order: 8

        autoHidePanel:
            title: 'Automatically hide panel on ...'
            description: 'Select on which event the panel should automatically disappear.'
            type: 'string'
            default: 'Success'
            enum: ['Never', 'Success', 'Error', 'Success, Error']
            order: 9

        autoHidePanelDelay:
            title: 'Panel-auto-hide delay'
            description: 'Delay after which panel is automatically hidden'
            type: 'integer'
            default: 3000
            order: 10

        autoHideNotifications:
            title: 'Automatically hide notifications on ...'
            description: 'Select which types of notifications should automatically disappear.'
            type: 'string'
            default: 'Info, Success'
            enum: ['Never', 'Info, Success', 'Error', 'Info, Success, Error']
            order: 11

        showStartCompilingNotification:
            title: 'Show \'Start Compiling\' Notification'
            description: 'If enabled a \'Start Compiling\' notification is shown.'
            type: 'boolean'
            default: false
            order: 12


    sassAutocompileView: null


    activate: (state) ->
        @sassAutocompileView = new SassAutocompileView(state.sassAutocompileViewState)

        atom.commands.add 'atom-workspace',
            'sass-autocompile:toggle-enabled': =>
                @toggleEnabled()

            'sass-autocompile:toggle-always-compress': =>
                @toggleAlwaysCompress()
                @toggleEnabled()

            'sass-autocompile:close-message-panel': =>
                @closeMessagePanel()

            @addMenuItems()


    deactivate: ->
        @sassAutocompileView.destroy()


    serialize: ->
        sassAutocompileViewState: @sassAutocompileView.serialize()


    toggleEnabled: ->
        atom.config.set('sass-autocompile.enabled', !atom.config.get('sass-autocompile.enabled'))
        if atom.config.get('sass-autocompile.enabled')
            atom.notifications.addInfo 'SASS-AutoCompile: Enabled auto-compilation'
        else
            atom.notifications.addInfo 'SASS-AutoCompile: Disabled auto-compilation'
        @updateMenuItems()


    toggleAlwaysCompress: ->
        atom.config.set('sass-autocompile.alwaysCompress', !atom.config.get('sass-autocompile.alwaysCompress'))
        @updateMenuItems()


    addMenuItems: ->
        atom.menu.add [ {
            label: 'Packages'
            submenu : [
                {
                    label: 'SASS Autocompile'
                    submenu : [
                        { label : 'Enable', command: 'sass-autocompile:toggle-enabled' }
                        { label : 'Always Compress', command: 'sass-autocompile:toggle-always-compress' }
                    ]
                }
            ]
        } ]
        @updateMenuItems()


    updateMenuItems: ->
        for menu in atom.menu.template
            if menu.label == 'Packages' || menu.label == '&Packages'
                for submenu in menu.submenu
                    if submenu.label == 'SASS Autocompile'
                        item = submenu.submenu[0]
                        item.label = (if atom.config.get('sass-autocompile.enabled') then 'Disable' else 'Enable')

                        item = submenu.submenu[1]
                        item.label = (if atom.config.get('sass-autocompile.alwaysCompress') then 'Disable' else 'Enable') + ' always compress'

        atom.menu.update()


    closeMessagePanel: ->
        @sassAutocompileView.hidePanel()
