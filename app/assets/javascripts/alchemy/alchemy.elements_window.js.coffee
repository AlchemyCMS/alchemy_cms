window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.ElementsWindow =

  init: (path, options, callback) ->
    self = Alchemy.ElementsWindow
    $dialog = $('<div style="display: none" id="alchemyElementWindow"></div>')
    closeCallback = ->
      $dialog.dialog "destroy"
      $("#alchemyElementWindow").remove()
      Alchemy.ElementsWindow.button.enable()

    self.path = path
    self.callback = callback
    $dialog.html Alchemy.getOverlaySpinner(width: 420, height: 300)
    self.dialog = $dialog
    $('#main_content').append($dialog)
    Alchemy.ElementsWindow.currentWindow = $dialog.dialog(
      modal: false
      minWidth: 420
      minHeight: 300
      height: $(window).height() - 88
      title: options.texts.title
      show: "fade"
      hide: "fade"
      position:
        my: "right bottom", at: "right-4px bottom-4px"
      closeOnEscape: false
      create: ->
        $dialog.before Alchemy.ElementsWindow.createToolbar(options.toolbarButtons)

      open: (event, ui) ->
        Alchemy.ElementsWindow.button.disable()
        Alchemy.ElementsWindow.reload callback

      beforeClose: ->
        if Alchemy.isPageDirty()
          Alchemy.openConfirmWindow
            title: options.texts.dirtyTitle
            message: options.texts.dirtyMessage
            okLabel: options.texts.okLabel
            cancelLabel: options.texts.cancelLabel
            okCallback: closeCallback

          false
        else
          true

      close: closeCallback
    )

  button:
    enable: ->
      $("div#show_element_window").removeClass("disabled").find("a").removeAttr "tabindex"

    disable: ->
      $("div#show_element_window").addClass("disabled").find("a").attr "tabindex", "-1"

    toggle: ->
      if $("div#show_element_window").hasClass("disabled")
        Alchemy.ElementsWindow.button.enable()
      else
        Alchemy.ElementsWindow.button.disable()

  createToolbar: (buttons) ->
    $toolbar = $("<div id=\"overlay_toolbar\"></div>")
    btn = undefined
    i = 0
    while i < buttons.length
      btn = buttons[i]
      $toolbar.append Alchemy.ToolbarButton(
        buttonTitle: btn.title
        buttonLabel: btn.label
        iconClass: btn.iconClass
        onClick: btn.onClick
        buttonId: btn.buttonId
      )
      i++
    $toolbar

  reload: ->
    self = Alchemy.ElementsWindow
    $.ajax
      url: self.path
      success: (data, textStatus, XMLHttpRequest) ->
        self.dialog.html data
        Alchemy.Buttons.observe "#alchemyElementWindow"
        Alchemy.overlayObserver "#alchemyElementWindow"
        Alchemy.Datepicker "#alchemyElementWindow input.date, #alchemyElementWindow input[type=\"date\"]"
        self.callback.call()  if self.callback

      error: (XMLHttpRequest, textStatus, errorThrown) ->
        Alchemy.AjaxErrorHandler $dialog, XMLHttpRequest.status, textStatus, errorThrown
