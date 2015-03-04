SassAutocompileView = require './sass-autocompile-view'

module.exports =

    config:
        enabled:
            type: 'boolean'
            default: true
            description:
                "This option en-/disables auto compiling on save."

        alwaysCompress:
            type: 'boolean'
            default: false
            description:
                "Enabling this option overrides 'compress: true' parameter"

    sassAutocompileView: null

    activate: (state) ->
        @sassAutocompileView = new SassAutocompileView(state.sassAutocompileViewState)

        atom.commands.add 'atom-workspace',
            'sass-autocompile:toggle-enabled': =>
                @toggleEnabled()

            'sass-autocompile:toggle-always-compress': =>
                @toggleAlwaysCompress()

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
