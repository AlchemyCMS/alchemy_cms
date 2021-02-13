class window.Alchemy.ConfirmDialog extends Alchemy.Dialog

  DEFAULTS:
    header_height: 36
    size: '300x100'
    padding: true
    modal: true
    title: 'Please confirm'
    ok_label: 'Yes'
    cancel_label: 'No'
    on_ok: ->

  constructor: (@message, @options = {}) ->
    super('', @options)

  load: ->
    @dialog_title.text @options.title
    @dialog_body.html "<p>#{@message}</p>"
    @dialog_body.append @build_buttons()
    @bind_buttons()

  build_buttons: ->
    $btn_container = $('<div class="alchemy-dialog-buttons" />')
    @cancel_button = $("<button class=\"cancel secondary\">#{@options.cancel_label}</button>")
    @ok_button = $("<button class=\"confirm\">#{@options.ok_label}</button>")
    $btn_container.append(@cancel_button)
    $btn_container.append(@ok_button)
    $btn_container

  bind_buttons: ->
    @cancel_button.focus()
    @cancel_button.click =>
      @close()
      Alchemy.Buttons.enable()
      false
    @ok_button.click =>
      @close()
      @options.on_ok()
      false

# Opens a confirm dialog
#
# Arguments:
#
# message - The message that will be displayed to the user (String)
#
# Options:
#
#   title: ''         - The title of the overlay window (String)
#   cancel_label: ''   - The label of the cancel button (String)
#   ok_label: ''       - The label of the ok button (String)
#   on_ok: null  - The function to invoke on confirmation (Function)
#
window.Alchemy.openConfirmDialog = (message, options = {}) ->
  dialog = new Alchemy.ConfirmDialog(message, options)
  dialog.open()

# Opens a confirm to delete dialog
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
#   ok_label: ''      - The label for the ok button (String)
#   cancel_label: ''  - The label for the cancel button (String)
#
window.Alchemy.confirmToDeleteDialog = (url, opts) ->
  options =
    on_ok: ->
      Alchemy.pleaseWaitOverlay()
      $.ajax
        url: url
        type: "DELETE"
        error: (xhr, status, error) ->
          type = if xhr.status == 403 then 'warning' else 'error'
          Alchemy.growl(xhr.responseText || error, type)
        complete: () ->
          Alchemy.pleaseWaitOverlay(false)

  $.extend(options, opts)
  Alchemy.openConfirmDialog options.message, options
