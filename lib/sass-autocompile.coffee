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

        notifications:
            title: 'Notifications'
            description: 'Select which types of notifications you wish to see.'
            type: 'string'
            default: 'Panel'
            enum: ['Panel', 'Notifications', 'Panel, Notifications']
            order: 3

        autoHidePanel:
            title: 'Automatically hide panel on ...'
            description: 'Select on which event the panel should automatically disappear.'
            type: 'string'
            default: 'Success'
            enum: ['Never', 'Success', 'Error', 'Success, Error']
            order: 4

        autoHidePanelDelay:
            title: 'Panel-auto-hide delay'
            description: 'Delay after which panel is automatically hidden'
            type: 'integer'
            default: 3000
            order: 5

        autoHideNotifications:
            title: 'Automatically hide notifications on ...'
            description: 'Select which types of notifications should automatically disappear.'
            type: 'string'
            default: 'Info, Success'
            enum: ['Never', 'Info, Success', 'Error', 'Info, Success, Error']
            order: 6

        showStartCompilingNotification:
            title: 'Show \'Start Compiling\' Notification'
            description: 'If enabled a \'Start Compiling\' notification is shown.'
            type: 'boolean'
            default: false
            order: 7


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
