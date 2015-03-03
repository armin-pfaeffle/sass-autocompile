SassAutocompileView = require './sass-autocompile-view'

module.exports =
    sassAutocompileView: null

    activate: (state) ->
        console.log "SASS-AUTOCOMPILT: activate"
        @sassAutocompileView = new SassAutocompileView(state.sassAutocompileViewState)

    deactivate: ->
        @sassAutocompileView.destroy()

    serialize: ->
        sassAutocompileViewState: @sassAutocompileView.serialize()
