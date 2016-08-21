module.exports =
class SassAutocompileOptions

    @OPTIONS_PREFIX = 'sass-autocompile.'


    @get: (name) ->
        return atom.config.get(SassAutocompileOptions.OPTIONS_PREFIX + name)


    @set: (name, value) ->
        atom.config.set(SassAutocompileOptions.OPTIONS_PREFIX + name, value)


    @unset: (name) ->
        atom.config.unset(SassAutocompileOptions.OPTIONS_PREFIX + name)


    constructor: () ->
        @initialize()


    initialize: () ->
        # General options
        @compileOnSave = SassAutocompileOptions.get('compileOnSave')
        @compileEverySassFiles = SassAutocompileOptions.get('compileFiles') is 'Every SASS file'
        @compileOnlyFirstLineCommentFiles = SassAutocompileOptions.get('compileFiles') is 'Only with first-line-comment'
        @compilePartials = SassAutocompileOptions.get('compilePartials')
        @checkOutputFileAlreadyExists = SassAutocompileOptions.get('checkOutputFileAlreadyExists')
        @directlyJumpToError = SassAutocompileOptions.get('directlyJumpToError')
        @showCompileSassItemInTreeViewContextMenu = SassAutocompileOptions.get('showCompileSassItemInTreeViewContextMenu')

        # SASS compile options
        @compileCompressed = SassAutocompileOptions.get('compileCompressed')
        @compileCompact = SassAutocompileOptions.get('compileCompact')
        @compileNested = SassAutocompileOptions.get('compileNested')
        @compileExpanded = SassAutocompileOptions.get('compileExpanded')
        @compressedFilenamePattern = SassAutocompileOptions.get('compressedFilenamePattern')
        @compactFilenamePattern = SassAutocompileOptions.get('compactFilenamePattern')
        @nestedFilenamePattern = SassAutocompileOptions.get('nestedFilenamePattern')
        @expandedFilenamePattern = SassAutocompileOptions.get('expandedFilenamePattern')

        @indentType = SassAutocompileOptions.get('indentType')
        @indentWidth = SassAutocompileOptions.get('indentWidth')
        @linefeed = SassAutocompileOptions.get('linefeed')
        @sourceMap = SassAutocompileOptions.get('sourceMap')
        @sourceMapEmbed = SassAutocompileOptions.get('sourceMapEmbed')
        @sourceMapContents = SassAutocompileOptions.get('sourceMapContents')
        @sourceComments = SassAutocompileOptions.get('sourceComments')
        @includePath = SassAutocompileOptions.get('includePath')
        @precision = SassAutocompileOptions.get('precision')
        @importer = SassAutocompileOptions.get('importer')
        @functions = SassAutocompileOptions.get('functions')

        # Notification options
        @showInfoNotification = SassAutocompileOptions.get('notifications') in ['Notifications', 'Panel, Notifications']
        @showSuccessNotification = SassAutocompileOptions.get('notifications') in ['Notifications', 'Panel, Notifications']
        @showWarningNotification = SassAutocompileOptions.get('notifications') in ['Notifications', 'Panel, Notifications']
        @showErrorNotification = SassAutocompileOptions.get('notifications') in ['Notifications', 'Panel, Notifications']

        @autoHideInfoNotification = SassAutocompileOptions.get('autoHideNotifications') in ['Info, Success', 'Info, Success, Error']
        @autoHideSuccessNotification = SassAutocompileOptions.get('autoHideNotifications') in ['Info, Success', 'Info, Success, Error']
        @autoHideErrorNotification = SassAutocompileOptions.get('autoHideNotifications') in ['Error', 'Info, Success, Error']

        @showPanel = SassAutocompileOptions.get('notifications') in ['Panel', 'Panel, Notifications']

        @autoHidePanelOnSuccess = SassAutocompileOptions.get('autoHidePanel') in ['Success', 'Success, Error']
        @autoHidePanelOnError = SassAutocompileOptions.get('autoHidePanel') in ['Error', 'Success, Error']
        @autoHidePanelDelay = SassAutocompileOptions.get('autoHidePanelDelay')

        @showStartCompilingNotification = SassAutocompileOptions.get('showStartCompilingNotification')
        @showAdditionalCompilationInfo = SassAutocompileOptions.get('showAdditionalCompilationInfo')
        @showNodeSassOutput  = SassAutocompileOptions.get('showNodeSassOutput')
        @showOldParametersWarning  = SassAutocompileOptions.get('showOldParametersWarning')

        # Advanced options
        @nodeSassTimeout = SassAutocompileOptions.get('nodeSassTimeout')
        @nodeSassPath = SassAutocompileOptions.get('nodeSassPath')
