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
    error_type = "warning"
    $div = $('<div class="with_padding" />')
    $dialog.html $div
    switch status
      when 0
        error_header = "The server does not respond."
        error_body = "Please check server and try again."
      when 403
        error_header = "You are not authorized!"
        error_body = "Please close this window."
      else
        error_header = "#{errorThrown} (#{status})"
        error_body = "Please check log and try again."
        error_type = "error"
    $errorDiv = $("<div id=\"errorExplanation\" class=\"ajax_status_code #{error_type}\" />")
    $errorDiv.append "<h2>#{error_header}</h2>"
    $errorDiv.append "<p>#{error_body}</p>"
    $div.append $errorDiv

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
    Alchemy.ConfirmationWindow = $confirmation.dialog
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
      close: ->
        $("#alchemyConfirmation").remove()

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

  # Opens a new dialog window
  #
  # Arguments are:
  #
  #   url: the url to query to get the window body (String)
  #   opts: An options object that holds all additional options (Object)
  #
  # Options are:
  #
  #   title: ''              - The title for the overlay window (String)
  #   width: 400             - The width of the window (Number)
  #   height: 300            - The height of the window (Number)
  #   resizable: false       - Make the overlay resizable (Boolean)
  #   modal: true            - Make the window a modal dialog (Boolean)
  #   close_on_escape: true  - Should the overlay close on escape key (Boolean)
  #   overflow: true         - Display overflowing content, or show scrollbars (Boolean)
  #   image_loader: true     - Init the image loader after opening the dialog (Boolean)
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
      close_on_escape: true
      image_loader_color: '#fff'
    $.extend(options, opts)
    if options.width is "fullscreen"
      options.width = $(window).width() - 50
      options.height = $(window).height() - 50
    $dialog = $('<div style="display: none" class="alchemy_overlay" />')
    $dialog.appendTo "body"
    $dialog.html Alchemy.getOverlaySpinner
      width: (if options.width is "auto" then 400 else options.width)
      height: (if options.height is "auto" then 300 else options.height)
    Alchemy.CurrentWindow = $dialog.dialog
      modal: options.modal
      minWidth: (if options.width is "auto" then 400 else options.width)
      minHeight: (if options.height is "auto" then 300 else options.height)
      maxHeight: options.maxHeight
      title: options.title
      resizable: options.resizable
      show: "fade"
      hide: "fade"
      closeOnEscape: options.close_on_escape
      open: (event, ui) ->
        $.ajax
          url: url
          success: (data, textStatus, XMLHttpRequest) ->
            widget = $dialog.dialog("widget")
            if XMLHttpRequest.getResponseHeader('Content-Type').match(/javascript/)
              $dialog.empty()
            else
              $dialog.html(data)
              $dialog.css(overflow: (if options.overflow then "visible" else "auto"))
              widget.css(overflow: (if options.overflow then "visible" else "hidden"))
              if options.width is "auto"
                widget.css left: (($(window).width() / 2) - ($dialog.width() / 2))
              if options.height is "auto"
                widget.css top: ($(window).height() - $dialog.dialog("widget").height()) / 2
              Alchemy.GUI.init(Alchemy.CurrentWindow)
              if options.image_loader
                Alchemy.ImageLoader Alchemy.CurrentWindow, {color: options.image_loader_color}
              Alchemy.watchRemoteForms($dialog)
          error: (XMLHttpRequest, textStatus, errorThrown) ->
            Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown)
          complete: (jqXHR, textStatus) ->
            Alchemy.Buttons.enable()
      close: ->
        $dialog.remove()

  watchRemoteForms: (dialog) ->
    form = $('[data-remote="true"]', dialog)
    form.bind "ajax:complete", (e, xhr, status) ->
      if status == 'success'
        if xhr.getResponseHeader('Content-Type').match(/javascript/)
          Alchemy.closeCurrentWindow()
        else
          dialog.html(xhr.responseText)
          Alchemy.GUI.init(dialog)
          Alchemy.watchRemoteForms(dialog)
      else
        Alchemy.AjaxErrorHandler(dialog, xhr.status, status)

  # Closes the current dialog
  #
  # You can pass a callback function that will be executed after dialog gets closed.
  #
  closeCurrentWindow: (callback) ->
    dialog = Alchemy.CurrentWindow || $(".alchemy_overlay")
    if callback
      dialog.on "dialogclose", (event, ui) ->
        callback()
        dialog.remove()
    Alchemy.CurrentWindow = undefined
    dialog.dialog("close")
    true

  # Opens an image in an overlay
  # Used by the picture library
  zoomImage: (url, title, width, height) ->
    $doc_width = $(window).width()
    $doc_height = $(window).height()
    if width > $doc_width
      width = 'fullscreen'
    if height > $doc_height
      height = $doc_height
    Alchemy.openWindow url,
      width: width
      height: height
      maxHeight: height
      title: title
      overflow: false
      modal: false
      image_loader_color: '#000'

  # Trash window methods
  TrashWindow:

    # Opens the trash window
    open: (page_id, title) ->
      Alchemy.TrashWindow.current = Alchemy.openWindow(
        Alchemy.routes.admin_trash_path(page_id),
        title: title,
        width: 380,
        height: 450,
        maxHeight: $(window).height() - 50,
        modal: false
      )

    # Refreshes the trash window
    refresh: (page_id) ->
      if Alchemy.TrashWindow.current
        Alchemy.TrashWindow.current.html Alchemy.getOverlaySpinner(width: 380, height: 270)
        $.get Alchemy.routes.admin_trash_path(page_id), (html) ->
          Alchemy.TrashWindow.current.html html

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
        okLabel: options.okLabel || options.ok_label, #hmpf
        cancelLabel: options.cancelLabel || options.cancel_label, #hmpf
        okCallback: ->
          Alchemy.pleaseWaitOverlay()
          self.form.submit()
          return
      )
      false
