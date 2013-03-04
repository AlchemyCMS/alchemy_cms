# This module holds methods for all kind of overlay windows in Alchemy

window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

$.extend Alchemy,

  # Returns a HTML div container with a spinner inside made with spin.js
  #
  # Options:
  #
  #   width: 400   - The width of the spinner container (Number)
  #   height: 300  - The height of the spinner container (Number)
  #
  getOverlaySpinner: (opts) ->
    options = {width: 400, height: 300}
    $.extend(options, opts)
    $spinner_container = $('<div class="spinner_container"/>').css(
      width: options.width
      height: options.height
    )
    spinner = Alchemy.Spinner.medium(
      top: options.height / 2 - 8 + "px"
      left: options.width / 2 - 8 + "px"
    )
    spinner.spin $spinner_container[0]
    $spinner_container

  # Display a error message for dialogs
  # Used by Alchemy.openWindow if errors happen
  AjaxErrorHandler: ($dialog, status, textStatus, errorThrown) ->
    $div = $('<div class="with_padding" />')
    $errorDiv = $("<div id=\"errorExplanation\" class=\"ajax_status_code_#{status}\" />")
    $dialog.html $div
    $div.append $errorDiv
    if status is 0
      $errorDiv.append "<h2>The server does not respond.</h2>"
      $errorDiv.append "<p>Please check server and try again.</p>"
    else
      $errorDiv.append "<h2>" + errorThrown + " (" + status + ")</h2>"
      $errorDiv.append "<p>Please check log and try again.</p>"
    return

  # Adds buttons into a toolbar inside of overlay windows
  # Used by Alchemy.ElementsWindow
  ToolbarButton: (options) ->
    $btn = $('<div class="button_with_label" />')
    if options.buttonId
      $btn.attr(id: options.buttonId)
    $lnk = $("<a title='#{options.buttonTitle}' class='icon_button' href='#' />")
    $lnk.click options.onClick
    $lnk.append "<span class='icon #{options.iconClass}' />"
    $btn.append $lnk
    $btn.append "<br><label>#{options.buttonLabel}</label>"
    $btn

  # Opens a confirm window
  #
  # Options:
  #
  #   title: ''         - The title of the overlay window (String)
  #   message: ''       - The message that will be displayed to the user (String)
  #   cancelLabel: ''   - The label of the cancel button (String)
  #   okLabel: ''       - The label of the ok button (String)
  #   okCallback: null  - The function to invoke on confirmation (Function)
  #
  openConfirmWindow: (options = {}) ->
    $confirmation = $('<div style="display: none" id="alchemyConfirmation" />')
    $confirmation.appendTo "body"
    $confirmation.html "<p>" + options.message + "</p>"
    Alchemy.ConfirmationWindow = $confirmation.dialog(
      resizable: false
      minHeight: 100
      minWidth: 300
      modal: true
      title: options.title
      show: "fade"
      hide: "fade"
      buttons: [
        {
          text: options.cancelLabel,
          click: ->
            $(this).dialog "close"
            Alchemy.Buttons.enable()
            return
        },
        {
          text: options.okLabel,
          click: ->
            $(this).dialog "close"
            options.okCallback()
            return
        }
      ]
      open: ->
        Alchemy.Buttons.observe "#alchemyConfirmation"
        return
      close: ->
        $("#alchemyConfirmation").remove()
        return
    )
    return

  # Opens a confirm to delete window
  #
  # Arguments:
  #
  #   url  - The url to the server delete action. Uses DELETE as HTTP method. (String)
  #   opts - An options object (Object)
  #
  # Options:
  #
  #   title: ''        - The title of the confirmation window (String)
  #   message: ''      - The message that will be displayed to the user (String)
  #   okLabel: ''      - The label for the ok button (String)
  #   cancelLabel: ''  - The label for the cancel button (String)
  #
  confirmToDeleteWindow: (url, opts) ->
    options =
      title: ''
      message: ''
      okLabel: ''
      cancelLabel: ''
    $.extend(options, opts)
    Alchemy.openConfirmWindow
      message: options.message
      title: options.title
      okLabel: options.okLabel
      cancelLabel: options.cancelLabel
      okCallback: ->
        Alchemy.pleaseWaitOverlay()
        $.ajax
          url: url
          type: "DELETE"
        return
    return

  # Opens a new dialog window
  #
  # Arguments are:
  #
  #   url: the url to query to get the window body (String)
  #   opts: An options object that holds all additional options (Object)
  #
  # Options are:
  #
  #   title: ''           - The title for the overlay window (String)
  #   width: 400          - The width of the window (Number)
  #   height: 300         - The height of the window (Number)
  #   resizable: false    - Make the overlay resizable (Boolean)
  #   modal: true         - Make the window a modal dialog (Boolean)
  #   overflow: true      - Display overflowing content, or show scrollbars (Boolean)
  #   image_loader: true  - Init the image loader after opening the dialog (Boolean)
  #
  openWindow: (url, opts) ->
    options =
      title: ''
      width: 400
      height: 300
      resizable: false
      modal: true
      overflow: true
      image_loader: true
    $.extend(options, opts)
    if options.width is "fullscreen"
      options.width = $(window).width() - 50
      options.height = $(window).height() - 50
    $dialog = $('<div style="display: none" id="alchemyOverlay" />')
    $dialog.appendTo "body"
    $dialog.html Alchemy.getOverlaySpinner(
      width: (if options.width is "auto" then 400 else options.width)
      height: (if options.height is "auto" then 300 else options.height)
    )
    Alchemy.CurrentWindow = $dialog.dialog(
      modal: options.modal
      minWidth: (if options.width is "auto" then 400 else options.width)
      minHeight: (if options.height is "auto" then 300 else options.height)
      title: options.title
      resizable: options.resizable
      show: "fade"
      hide: "fade"
      width: options.width
      open: (event, ui) ->
        $.ajax
          url: url
          success: (data, textStatus, XMLHttpRequest) ->
            widget = $dialog.dialog("widget")
            $dialog.html(data)
            $dialog.css(overflow: (if options.overflow then "visible" else "auto"))
            widget.css(overflow: (if options.overflow then "visible" else "hidden"))
            if options.width is "auto"
              widget.css left: (($(window).width() / 2) - ($dialog.width() / 2))
            if options.height is "auto"
              widget.css top: ($(window).height() - $dialog.dialog("widget").height()) / 2
            Alchemy.SelectBox "#alchemyOverlay"
            Alchemy.Datepicker '#alchemyOverlay input.date, #alchemyOverlay input[type="date"]'
            Alchemy.Buttons.observe "#alchemyOverlay"
            Alchemy.overlayObserver "#alchemyOverlay"
            if options.image_loader
              Alchemy.ImageLoader '#alchemyOverlay img', {color: '#fff'}
            return
          error: (XMLHttpRequest, textStatus, errorThrown) ->
            Alchemy.AjaxErrorHandler $dialog, XMLHttpRequest.status, textStatus, errorThrown
            return
          complete: (jqXHR, textStatus) ->
            Alchemy.Buttons.enable()
            return
        return
      close: ->
        $dialog.remove()
        return
    )
    return

  # Closes the current dialog
  closeCurrentWindow: ->
    if Alchemy.CurrentWindow
      Alchemy.CurrentWindow.dialog "close"
      Alchemy.CurrentWindow = null
    else
      $("#alchemyOverlay").dialog "close"
    true

  # Opens an image in an overlay
  # Used by the picture library
  zoomImage: (url, title, width, height) ->
    window_height = height
    window_width = width
    $doc_width = $(window).width()
    $doc_height = $(window).height()
    window_width = $doc_width - 50  if width > $doc_width
    window_height = $doc_height - 50  if height > $doc_height
    $dialog = $("<div style=\"display:none\" id=\"alchemyOverlay\"></div>")
    $dialog.appendTo "body"
    $dialog.html Alchemy.getOverlaySpinner({width: width, height: height})
    $dialog.dialog
      modal: false
      minWidth: (if window_width < 320 then 320 else window_width)
      minHeight: (if window_height < 240 then 240 else window_height)
      title: title
      show: "fade"
      hide: "fade"
      open: (event, ui) ->
        $.ajax
          url: url
          success: (data, textStatus, XMLHttpRequest) ->
            $dialog.html data
            return
          error: (XMLHttpRequest, textStatus, errorThrown) ->
            Alchemy.AjaxErrorHandler $dialog, XMLHttpRequest.status, textStatus, errorThrown
            return
        return
      close: ->
        $dialog.remove()
        return
    false

  # Trash window methods
  TrashWindow:

    # Opens the trash window
    open: (page_id, title) ->
      $dialog = $('<div style="display: none" id="alchemyTrashWindow" />')
      $dialog.appendTo("body")
      $dialog.html Alchemy.getOverlaySpinner({width: 380, height: 450})
      Alchemy.TrashWindow.current = $dialog.dialog(
        modal: false
        width: 380
        minHeight: 450
        maxHeight: $(window).height() - 50
        title: title
        resizable: false
        show: "fade"
        hide: "fade"
        open: (event, ui) ->
          $.ajax
            url: Alchemy.routes.admin_trash_path(page_id)
            success: (data, textStatus, XMLHttpRequest) ->
              $dialog.html data
              # Need this for DragnDrop elements into elements window.
              # Badly this is screwing up maxHeight option
              $dialog.css(overflow: "visible").dialog("widget").css overflow: "visible"
              Alchemy.overlayObserver "#alchemyTrashWindow"
              return
            error: (XMLHttpRequest, textStatus, errorThrown) ->
              Alchemy.AjaxErrorHandler $dialog, XMLHttpRequest.status, textStatus, errorThrown
              return
          return
        close: ->
          $dialog.remove()
          return
      )
      return

    # Refreshes the trash window
    refresh: (page_id) ->
      if $("#alchemyTrashWindow").length > 0
        $("#alchemyTrashWindow").html Alchemy.getOverlaySpinner(
          width: 380
          height: 270
        )
        $.get Alchemy.routes.admin_trash_path(page_id), (html) ->
          $("#alchemyTrashWindow").html html
          return
      return

  # Adds onClick events for Alchemy overlays
  #
  # Elements are all links that have a data-alchemy-overlay or data-alchemy-confirm-delete
  # and all input/buttons that have a data-alchemy-confirm attribute.
  #
  # Arguments:
  #
  #   You can pass a scope so that only elements inside this scope are queried
  #
  # The observer takes the href attribute as url for the overlay window.
  #
  # See Alchemy.openWindow for further options you can add to the data attribute
  #
  overlayObserver: (scope) ->
    $("a[data-alchemy-overlay]", scope).click (event) ->
      $this = $(this)
      options = $this.data("alchemy-overlay")
      event.preventDefault()
      Alchemy.openWindow $this.attr("href"), options
      false
    $("a[data-alchemy-confirm-delete]", scope).click (event) ->
      $this = $(this)
      options = $this.data("alchemy-confirm-delete")
      event.preventDefault()
      Alchemy.confirmToDeleteWindow $this.attr("href"),
        title: options.title,
        message: options.message,
        okLabel: options.ok_label,
        cancelLabel: options.cancel_label
      false
    $("input[data-alchemy-confirm], button[data-alchemy-confirm]", scope).click (event) ->
      $this = $(this)
      self = this
      options = $this.data("alchemy-confirm")
      event.preventDefault()
      Alchemy.openConfirmWindow $.extend(options,
        okCallback: ->
          Alchemy.pleaseWaitOverlay()
          self.form.submit()
          return
      )
      false
