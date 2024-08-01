# Dialog windows
#
class window.Alchemy.Dialog

  DEFAULTS:
    header_height: 36
    size: '400x300'
    padding: true
    title: ''
    modal: true
    overflow: 'visible'
    ready: ->
    closed: ->

  # Arguments:
  #  - url: The url to load the content from via ajax
  #  - options: A object holding options
  #    - size: The maximum size of the Dialog
  #    - title: The title of the Dialog
  constructor: (@url, @options = {}) ->
    @options = $.extend({}, @DEFAULTS, @options)
    @$document = $(document)
    @$window = $(window)
    @$body = $('body')
    size = @options.size.split('x')
    @width = parseInt(size[0], 10)
    @height = parseInt(size[1], 10)
    @build()

  # Opens the Dialog and loads the content via ajax.
  open: ->
    @dialog.trigger 'Alchemy.DialogOpen'
    @bind_close_events()
    window.requestAnimationFrame =>
      @dialog_container.addClass('open')
      @overlay.addClass('open') if @overlay?
    @$body.addClass('prevent-scrolling')
    Alchemy.currentDialogs.push(this)
    @load()
    true

  # Closes the Dialog and removes it from the DOM
  close: ->
    @dialog.trigger 'DialogClose.Alchemy'
    @$document.off 'keydown'
    @dialog_container.removeClass('open')
    @overlay.removeClass('open') if @overlay?
    @$document.on 'webkitTransitionEnd transitionend oTransitionEnd', =>
      @$document.off 'webkitTransitionEnd transitionend oTransitionEnd'
      @dialog_container.remove()
      @overlay.remove() if @overlay?
      @$body.removeClass('prevent-scrolling')
      Alchemy.currentDialogs.pop(this)
      if @options.closed?
        @options.closed()
    true

  # Loads the content via ajax and replaces the Dialog body with server response.
  load: ->
    @show_spinner()
    $.get @url, (data) =>
      @replace(data)
    .fail (xhr) =>
      @show_error(xhr)
    true

  # Reloads the Dialog content
  reload: ->
    @dialog_body.empty()
    @load()

  # Replaces the dialog body with given content and initializes it.
  replace: (data) ->
    @remove_spinner()
    @dialog_body.hide()
    @dialog_body.html(data)
    @init()
    @dialog[0].dispatchEvent(new CustomEvent(
      "DialogReady.Alchemy",
      bubbles: true
      detail:
        body: @dialog_body[0]
    ))
    if @options.ready?
      @options.ready(@dialog_body)
    @dialog_body.show()
    true

  # Adds a spinner into Dialog body
  show_spinner: ->
    @spinner = new Alchemy.Spinner('medium')
    @spinner.spin(@dialog_body[0])

  # Removes the spinner from Dialog body
  remove_spinner: ->
    @spinner.stop()

  # Initializes the Dialog body
  init: ->
    Alchemy.GUI.init(@dialog_body)
    turbo_frame = @dialog_body[0].querySelector("turbo-frame")
    if turbo_frame
      # Need to redirect to the new location if the frame is missing
      # because of a redirect to a new page from server
      turbo_frame.addEventListener "turbo:frame-missing", (event) =>
        if event.detail.response.redirected
          event.detail.visit(event.detail.response.url)
          event.preventDefault()
        return
    @watch_remote_forms()

  # Watches ajax requests inside of dialog body and replaces the content accordingly
  watch_remote_forms: ->
    form = $('[data-remote="true"]', @dialog_body)
    form.bind "ajax:success", (event) =>
      xhr = event.detail[2]
      content_type = xhr.getResponseHeader('Content-Type')
      if content_type.match(/javascript/)
        return
      else
        @dialog_body.html(xhr.responseText)
        @init()
      return
    form.bind "ajax:error", (event, b, c) =>
      statusText = event.detail[1]
      xhr = event.detail[2]
      @show_error(xhr, statusText)
      return

  # Displays an error message
  show_error: (xhr, status_message, $container = @dialog_body) ->
    error_type = "warning"
    switch xhr.status
      when 0
        error_header = "The server does not respond."
        error_body = "Please check server and try again."
      when 403
        error_header = "You are not authorized!"
        error_body = "Please close this window."
      when 422
        @dialog_body.html(xhr.responseText)
        @init()
        return
      else
        error_type = "error"
        if status_message
          error_header = status_message
          console.error(xhr.responseText)
        else
          error_header = "#{xhr.statusText} (#{xhr.status})"
        error_body = "Please check log and try again."
    $errorDiv = $("<alchemy-message type=\"#{error_type}\">
      <h1>#{error_header}</h1>
      <p>#{error_body}</p>
    </alchemy-message>")
    $container.html $errorDiv

  # Binds close events on:
  # - Close button
  # - Overlay (if the Dialog is a modal)
  # - ESC Key
  bind_close_events: ->
    @close_button.on "click", =>
      @close()
      false
    @dialog_container.addClass('closable').on "click", (e) =>
      return true if e.target != @dialog_container.get(0)
      @close()
      false
    @$document.keydown (e) =>
      if e.which == 27
        @close()
        false
      else
        true

  # Builds the html structure of the Dialog
  build: ->
    @dialog_container = $('<div class="alchemy-dialog-container" />')
    @dialog = $('<div class="alchemy-dialog" />')
    @dialog_body = $('<div class="alchemy-dialog-body" />')
    @dialog_header = $('<div class="alchemy-dialog-header" />')
    @dialog_title = $('<div class="alchemy-dialog-title" />')
    @close_button = $('<a class="alchemy-dialog-close"><alchemy-icon name="close"></alchemy-icon></a>')
    @dialog_title.text(@options.title)
    @dialog_header.append(@dialog_title)
    @dialog_header.append(@close_button)
    @dialog.append(@dialog_header)
    @dialog.append(@dialog_body)
    @dialog_container.append(@dialog)
    @dialog.addClass('modal') if @options.modal
    @dialog_body.addClass('padded') if @options.padding
    if @options.modal
      @overlay = $('<div class="alchemy-dialog-overlay" />')
      @$body.append(@overlay)
    @$body.append(@dialog_container)
    @resize()
    @dialog

  # Sets the correct size of the dialog
  # It normalizes the given size, so that it never acceeds the window size.
  resize: ->
    padding = 16
    $doc_width = @$window.width()
    $doc_height = @$window.height()
    if @options.size == 'fullscreen'
      [@width, @height] = [$doc_width, $doc_height]
    if @width >= $doc_width
      @width = $doc_width - padding
    if @height >= $doc_height
      @height = $doc_height - padding - @DEFAULTS.header_height
    @dialog.css
      'width': @width
      'min-height': @height
      overflow: @options.overflow
    if @options.overflow == 'hidden'
      @dialog_body.css
        height: @height
        overflow: 'auto'
    else
      @dialog_body.css
        'min-height': @height
        overflow: 'visible'
    return

# Collection of all current dialog instances
window.Alchemy.currentDialogs = []

# Gets the last dialog instantiated, which is the current one.
window.Alchemy.currentDialog = ->
  length = Alchemy.currentDialogs.length
  return if length == 0
  Alchemy.currentDialogs[length - 1]

# Utility function to close the current Dialog
#
# You can pass a callback function, that gets triggered after the Dialog gets closed.
#
window.Alchemy.closeCurrentDialog = (callback) ->
  dialog = Alchemy.currentDialog()
  if dialog?
    dialog.options.closed = callback
    dialog.close()

# Utility function to open a new Dialog
window.Alchemy.openDialog = (url, options) ->
  if !url
    throw('No url given! Please provide an url.')
  dialog = new Alchemy.Dialog(url, options)
  dialog.open()

# Watches elements for Alchemy Dialogs
#
# Links having a data-alchemy-confirm-delete
# and input/buttons having a data-alchemy-confirm attribute get watched.
#
# You can pass a scope so that only elements inside this scope are queried.
#
# The href attribute of the link is the url for the overlay window.
#
# See Alchemy.Dialog for further options you can add to the data attribute
#
window.Alchemy.watchForDialogs = (scope = '#alchemy') ->
  $(scope).on 'click', '[data-alchemy-confirm-delete]', (event) ->
    $this = $(this)
    options = $this.data('alchemy-confirm-delete')
    Alchemy.confirmToDeleteDialog($this.attr('href'), options)
    event.preventDefault()
    return
  $(scope).on 'click', '[data-alchemy-confirm]', (event) ->
    options = $(this).data('alchemy-confirm')
    Alchemy.openConfirmDialog options.message, $.extend options,
      ok_label: options.ok_label
      cancel_label: options.cancel_label
      on_ok: =>
        Alchemy.pleaseWaitOverlay()
        @form.submit()
        return
    event.preventDefault()
    return
