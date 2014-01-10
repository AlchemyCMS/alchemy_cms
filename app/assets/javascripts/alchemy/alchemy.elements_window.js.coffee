window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# Adds buttons into a toolbar inside of overlay windows
Alchemy.ToolbarButton = (options) ->
  $btn = $('<div class="button_with_label" />')
  if options.buttonId
    $btn.attr(id: options.buttonId)
  $lnk = $("<a title='#{options.title}' class='icon_button' href='#' />")
  if options.hotkey
    $lnk.attr('data-alchemy-hotkey', options.hotkey)
  $lnk.click (e) ->
    e.preventDefault()
    options.onClick(e)
    false
  $lnk.append "<span class='icon #{options.iconClass}' />"
  $btn.append $lnk
  $btn.append "<br><label>#{options.label}</label>"
  $btn

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
    self.currentWindow = $dialog.dialog
      modal: false
      minWidth: 400
      minHeight: 300
      height: $(window).height() - 88
      title: options.texts.title
      show: "fade"
      hide: "fade"
      position:
        my: "right bottom", at: "right-4px bottom-4px"
      closeOnEscape: false
      dialogClass: 'alchemy-elements-window'
      create: ->
        $dialog.before Alchemy.ElementsWindow.createToolbar(options.toolbarButtons)
      open: (event, ui) ->
        Alchemy.ElementsWindow.button.disable()
        Alchemy.ElementsWindow.reload()
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
    $toolbar = $('<div id="overlay_toolbar"/>')
    for btn in buttons
      $toolbar.append Alchemy.ToolbarButton(btn)
    $toolbar

  reload: ->
    self = Alchemy.ElementsWindow
    $.ajax
      url: self.path
      success: (data, textStatus, XMLHttpRequest) ->
        self.dialog.html data
        Alchemy.GUI.init "#alchemyElementWindow"
        if self.callback
          self.callback.call()
      error: (XMLHttpRequest, textStatus, errorThrown) ->
        Alchemy.AjaxErrorHandler $dialog, XMLHttpRequest.status, textStatus, errorThrown
