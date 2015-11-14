{$, $$, View} = require('atom-space-pen-views')
{CompositeDisposable} = require('atom')

File = require('./helper/file')

fs = require('fs')


module.exports =
class SassAutocompileView extends View

    @captionPrefix = 'SASS-Autocompile: '
    @clickableLinksCounter = 0


    @content: ->
        @div class: 'sass-autocompile atom-panel panel-bottom', =>
            @div class: 'inset-panel', =>
                @div outlet: 'panelHeading', class: 'panel-heading no-border', =>
                    @span
                        outlet: 'panelHeaderCaption'
                        class: 'header-caption'
                    @span
                        outlet: 'panelOpenNodeSassOutput'
                        class: 'open-node-sass-output hide'
                        click: 'openNodeSassOutput'
                        'Show detailed output'
                    @span
                        outlet: 'panelLoading'
                        class: 'inline-block loading loading-spinner-tiny hide'
                    @div outlet: 'panelRightTopOptions', class: 'inline-block pull-right right-top-options', =>
                        @button
                            outlet: 'panelClose'
                            class: 'btn btn-close'
                            click: 'hidePanel'
                            'Close'
                @div
                    outlet: 'panelBody'
                    class: 'panel-body padded hide'


    constructor: (options, args...) ->
        super(args)
        @options = options
        @panel = atom.workspace.addBottomPanel
            item: this
            visible: false


    initialize: (serializeState) ->


    destroy: ->
        clearTimeout(@automaticHidePanelTimeout)
        @panel.destroy()
        @detach()


    updateOptions: (options) ->
        @options = options


    startCompilation: (args) ->
        @hasError = false
        @clearNodeSassOutput()

        if @options.showStartCompilingNotification
            if args.isCompileDirect
                @showInfoNotification('Start direct compilation')
            else
                @showInfoNotification('Start compilation', args.inputFilename)

        if @options.showPanel
            @showPanel(true)
            if @options.showStartCompilingNotification
                if args.isCompileDirect
                    @addText('Start direct compilation', 'terminal', 'info',)
                else
                    @addText(args.inputFilename, 'terminal', 'info', (evt) => @openFile(args.inputFilename, null, null, evt.target) )


    warning: (args) ->
        if @options.showWarningNotification
            @showWarningNotification('Warning', args.message)

        if @options.showPanel
            @showPanel()
            if args.outputFilename
                @addText(args.message, 'issue-opened', 'warning', (evt) => @openFile(args.outputFilename, evt.target))
            else
                @addText(args.message, 'issue-opened', 'warning')


    successfullCompilation: (args) ->
        @appendNodeSassOutput(args.nodeSassOutput)
        fileSize = File.fileSizeToReadable(args.statistics.after)

        # Notification
        caption = "Successfully compiled"
        details = args.outputFilename
        if @options.showAdditionalCompilationInfo
            details += "\n \nOutput style: " + args.outputStyle
            details += "\nDuration:     " + args.statistics.duration + " ms"
            details += "\nFile size:    " + fileSize.size + " " + fileSize.unit
        @showSuccessNotification(caption, details)

        # Panel
        if @options.showPanel
            @showPanel()

            # We have to store this value in a local variable, beacuse $$ methods can not see @options
            showAdditionalCompilationInfo = @options.showAdditionalCompilationInfo

            message = $$ ->
                @div class: 'success-text-wrapper', =>
                    @p class: 'icon icon-check text-success', =>
                        if args.isCompileDirect
                            @span class: '', 'Successfully compiled!'
                        else
                            @span class: '', args.outputFilename

                    if showAdditionalCompilationInfo
                        @p class: 'success-details text-info', =>
                            @span class: 'success-output-style', =>
                                @span 'Output style: '
                                @span class: 'value', args.outputStyle
                            @span class: 'success-duration', =>
                                @span 'Duration: '
                                @span class: 'value', args.statistics.duration + ' ms'
                            @span class: 'success-file-size', =>
                                @span 'File size: '
                                @span class: 'value', fileSize.size + ' ' + fileSize.unit

            @addText(message, 'check', 'success', (evt) => @openFile(args.outputFilename, evt.target))


    erroneousCompilation: (args) ->
        @hasError = true
        @appendNodeSassOutput(args.nodeSassOutput)

        # Notification
        caption = 'Compilation error'
        if args.message.file
            errorNotification = "ERROR:\n" + args.message.message
            if args.isCompileToFile
                errorNotification += "\n \nFILE:\n" + args.message.file
            errorNotification += "\n \nLINE:    " + args.message.line + "\nCOLUMN:  " + args.message.column
        else
            errorNotification = args.message
        @showErrorNotification(caption, errorNotification)

        # Panel
        if @options.showPanel
            @showPanel()

            if args.message.file
                errorMessage = $$ ->
                    @div class: 'open-error-file', =>
                        @p class: "icon icon-alert text-error", =>
                            @span class: "error-caption", 'Error:'
                            @span class: "error-text", args.message.message
                            if args.isCompileDirect
                                @span class: 'error-line', args.message.line
                                @span class: 'error-column', args.message.column

                        if args.isCompileToFile
                            @p class: 'error-details text-error', =>
                                @span class: 'error-file-wrapper', =>
                                    @span 'in:'
                                    @span class: 'error-file', args.message.file
                                    @span class: 'error-line', args.message.line
                                    @span class: 'error-column', args.message.column
                @addText(errorMessage, 'alert', 'error', (evt) => @openFile(args.message.file, args.message.line, args.message.column, evt.target))
            else if args.message.message
                @addText(args.message.message, 'alert', 'error', (evt) => @openFile(args.inputFilename, null, null, evt.target))
            else
                @addText(args.message, 'alert', 'error', (evt) => @openFile(args.inputFilename, null, null, evt.target))

        if @options.directlyJumpToError and args.message.file
            @openFile(args.message.file, args.message.line, args.message.column)


    appendNodeSassOutput: (output) ->
        if @nodeSassOutput
            @nodeSassOutput += "\n\n--------------------\n\n" + output
        else
            @nodeSassOutput = output


    clearNodeSassOutput: () ->
        @nodeSassOutput = undefined


    finished: (args) ->
        if @hasError
            @setCaption('Compilation error')
            if @options.autoHidePanelOnError
                @hidePanel(true)
        else
            @setCaption('Successfully compiled')
            if @options.autoHidePanelOnSuccess
                @hidePanel(true)

        @hideThrobber()
        @showRightTopOptions()

        if @nodeSassOutput
            @panelOpenNodeSassOutput.removeClass('hide')
        if @options.showNodeSassOutput
            @openNodeSassOutput()


    openFile: (filename, line, column, targetElement = null) ->
        if typeof filename is 'string'
            fs.exists filename, (exists) =>
                if exists
                    atom.workspace.open filename,
                        initialLine: if line then line - 1 else 0,
                        initialColumn: if column then column - 1 else 0
                else if targetElement
                    target = $(targetElement)
                    if not target.is('p.clickable')
                        target = target.parent()

                    target
                        .addClass('target-file-does-not-exist')
                        .removeClass('clickable')
                        .append($('<span>File does not exist!</span>').addClass('hint'))
                        .off('click')
                        .children(':first')
                            .removeClass('text-success text-warning text-info')


    openNodeSassOutput: () ->
        if @nodeSassOutput
            if not @nodeSassOutputEditor
                atom.workspace.open().then (editor) =>
                    @nodeSassOutputEditor = editor
                    editor.setText(@nodeSassOutput)

                    subscriptions = new CompositeDisposable
                    subscriptions.add editor.onDidSave =>
                        @nodeSassOutputEditor = null

                    subscriptions.add editor.onDidDestroy =>
                        @nodeSassOutputEditor = null
                        subscriptions.dispose()
            else
                pane = atom.workspace.paneForItem(@nodeSassOutputEditor)
                pane.activateItem(@nodeSassOutputEditor)


    showInfoNotification: (title, message) ->
        if @options.showInfoNotification
            atom.notifications.addInfo title,
                detail: message
                dismissable: !@options.autoHideInfoNotification


    showSuccessNotification: (title, message) ->
        if @options.showSuccessNotification
            atom.notifications.addSuccess title,
                detail: message
                dismissable: !@options.autoHideSuccessNotification


    showWarningNotification: (title, message) ->
        if @options.showWarningNotification
            atom.notifications.addWarning title,
                detail: message
                dismissable: !@options.autoWarningInfoNotification


    showErrorNotification: (title, message) ->
        if @options.showErrorNotification
            atom.notifications.addError title,
                detail: message
                dismissable: !@options.autoHideErrorNotification


    resetPanel: ->
        @setCaption('Processing...')
        @showThrobber()
        @hideRightTopOptions()
        @panelOpenNodeSassOutput.addClass('hide')
        @panelBody.addClass('hide').empty()


    showPanel: (reset = false) ->
        clearTimeout(@automaticHidePanelTimeout)

        if reset
            @resetPanel()

        @panel.show()


    hidePanel: (withDelay = false, reset = false)->
        clearTimeout(@automaticHidePanelTimeout)

        # We have to compare it to true because if close button is clicked, the withDelay
        # parameter is a reference to the button
        if withDelay == true
            @automaticHidePanelTimeout = setTimeout =>
                @hideThrobber()
                @panel.hide()
                if reset
                    @resetPanel()
            , @options.autoHidePanelDelay
        else
            @hideThrobber()
            @panel.hide()
            if reset
                @resetPanel()


    setCaption: (text) ->
        @panelHeaderCaption.html(SassAutocompileView.captionPrefix + text)


    addText: (text, icon, textClass, clickCallback) ->
        clickCounter = SassAutocompileView.clickableLinksCounter++
        wrapperClass = if clickCallback then "clickable clickable-#{clickCounter}" else ''

        spanClass = ''
        if icon
            spanClass = spanClass + (if spanClass isnt '' then ' ' else '') + "icon icon-#{icon}"
        if textClass
            spanClass = spanClass + (if spanClass isnt '' then ' ' else '') + "text-#{textClass}"

        if typeof text is 'object'
            wrapper = $$ ->
                @div class: wrapperClass
            wrapper.append(text)
            @panelBody.removeClass('hide').append(wrapper)
        else
            @panelBody.removeClass('hide').append $$ ->
                @p class: wrapperClass, =>
                    @span class: spanClass, text

        if clickCallback
            @find(".clickable-#{clickCounter}").on 'click', (evt) => clickCallback(evt)


    hideRightTopOptions: ->
        @panelRightTopOptions.addClass('hide')


    showRightTopOptions: ->
        @panelRightTopOptions.removeClass('hide')


    hideThrobber: ->
        @panelLoading.addClass('hide')


    showThrobber: ->
        @panelLoading.removeClass('hide')
