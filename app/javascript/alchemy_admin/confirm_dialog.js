class ConfirmDialog extends Alchemy.Dialog {
  constructor(message, options) {
    super("", {
      ...{
        header_height: 36,
        size: "300x100",
        padding: true,
        modal: true,
        title: "Please confirm",
        ok_label: "Yes",
        cancel_label: "No",
        on_ok: function () {}
      },
      ...options
    })

    this.message = message
  }

  load() {
    this.dialog_title.text(this.options.title)
    this.dialog_body.html("<p>" + this.message + "</p>")
    this.dialog_body.append(this.build_buttons())
    this.bind_buttons()
  }

  build_buttons() {
    const $btn_container = $('<div class="alchemy-dialog-buttons" />')
    this.cancel_button = $(
      '<button class="cancel secondary">' +
        this.options.cancel_label +
        "</button>"
    )
    this.ok_button = $(
      '<button class="confirm">' + this.options.ok_label + "</button>"
    )
    $btn_container.append(this.cancel_button)
    $btn_container.append(this.ok_button)
    return $btn_container
  }

  bind_buttons() {
    this.cancel_button.focus()
    this.cancel_button.click(() => {
      this.close()
      Alchemy.Buttons.enable()
    })
    this.ok_button.click(() => {
      this.close()
      this.options.on_ok()
    })
  }
}

/**
 *  Opens a confirm dialog
 *
 *  Arguments:
 *
 *  message - The message that will be displayed to the user (String)
 *
 *  Options:
 *
 *    title: ''         - The title of the overlay window (String)
 *    cancel_label: ''   - The label of the cancel button (String)
 *    ok_label: ''       - The label of the ok button (String)
 *    on_ok: null  - The function to invoke on confirmation (Function)
 *
 * @param message
 * @param options
 * @returns {*}
 */
function openConfirmDialog(message, options) {
  if (options == null) {
    options = {}
  }
  const dialog = new Alchemy.ConfirmDialog(message, options)
  return dialog.open()
}

/**
 * Opens a confirm to delete dialog
 *
 *  Arguments:
 *
 *    url  - The url to the server delete action. Uses DELETE as HTTP method. (String)
 *    opts - An options object (Object)
 *
 *  Options:
 *
 *    title: ''        - The title of the confirmation window (String)
 *    message: ''      - The message that will be displayed to the user (String)
 *    ok_label: ''      - The label for the ok button (String)
 *    cancel_label: ''  - The label for the cancel button (String)
 *
 * @param url
 * @param opts
 * @returns {*}
 */
function confirmToDeleteDialog(url, opts) {
  const options = {
    on_ok: function () {
      Alchemy.pleaseWaitOverlay()
      return $.ajax({
        url: url,
        type: "DELETE",
        error: function (xhr, status, error) {
          const type = xhr.status === 403 ? "warning" : "error"
          return Alchemy.growl(xhr.responseText || error, type)
        },
        complete: function () {
          return Alchemy.pleaseWaitOverlay(false)
        }
      })
    }
  }
  $.extend(options, opts)
  return Alchemy.openConfirmDialog(options.message, options)
}

export default {
  ConfirmDialog,
  openConfirmDialog,
  confirmToDeleteDialog
}
