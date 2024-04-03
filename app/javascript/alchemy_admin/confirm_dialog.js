import { growl } from "alchemy_admin/growler"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"

Alchemy.Dialog = window.Alchemy.Dialog || class Dialog {}

class ConfirmDialog extends Alchemy.Dialog {
  constructor(message, options = {}) {
    const DEFAULTS = {
      size: "300x100",
      title: "Please confirm",
      ok_label: "Yes",
      cancel_label: "No",
      on_ok() {}
    }

    options = { ...DEFAULTS, ...options }

    super("", options)
    this.message = message
    this.options = options
  }

  load() {
    this.dialog_title.text(this.options.title)
    this.dialog_body.html(`<p>${this.message}</p>`)
    this.dialog_body.append(this.build_buttons())
    this.bind_buttons()
  }

  build_buttons() {
    const $btn_container = $('<div class="alchemy-dialog-buttons" />')
    this.cancel_button = $(
      `<button class=\"cancel secondary\">${this.options.cancel_label}</button>`
    )
    this.ok_button = $(
      `<button class=\"confirm\">${this.options.ok_label}</button>`
    )
    $btn_container.append(this.cancel_button)
    $btn_container.append(this.ok_button)
    return $btn_container
  }

  bind_buttons() {
    this.cancel_button.trigger("focus")
    this.cancel_button.on("click", () => {
      this.close()
      return false
    })
    this.ok_button.on("click", () => {
      this.close()
      this.options.on_ok()
      return false
    })
  }
}

// Opens a confirm dialog
//
// Arguments:
//
// message - The message that will be displayed to the user (String)
//
// Options:
//
//   title: ''         - The title of the overlay window (String)
//   cancel_label: ''   - The label of the cancel button (String)
//   ok_label: ''       - The label of the ok button (String)
//   on_ok: null  - The function to invoke on confirmation (Function)
//
export function openConfirmDialog(message, options = {}) {
  const dialog = new ConfirmDialog(message, options)
  dialog.open()
  return dialog
}

// Opens a confirm to delete dialog
//
// Arguments:
//
//   url  - The url to the server delete action. Uses DELETE as HTTP method. (String)
//   opts - An options object (Object)
//
// Options:
//
//   title: ''        - The title of the confirmation window (String)
//   message: ''      - The message that will be displayed to the user (String)
//   ok_label: ''      - The label for the ok button (String)
//   cancel_label: ''  - The label for the cancel button (String)
//
export function confirmToDeleteDialog(url, opts = {}) {
  const options = {
    on_ok() {
      pleaseWaitOverlay()
      $.ajax({
        url,
        type: "DELETE",
        error(xhr, _status, error) {
          const type = xhr.status === 403 ? "warning" : "error"
          growl(xhr.responseText || error, type)
        },
        complete() {
          pleaseWaitOverlay(false)
        }
      })
    }
  }

  return openConfirmDialog(opts.message, { ...options, ...opts })
}
