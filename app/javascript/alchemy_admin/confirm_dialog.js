import { growl } from "alchemy_admin/growler"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"
import { createHtmlElement } from "alchemy_admin/utils/dom_helpers"
import { translate } from "alchemy_admin/i18n"

const getDefaults = () => ({
  // The default size of the dialog
  size: "300x100",
  title: translate("Please confirm"),
  ok_label: translate("Yes"),
  cancel_label: translate("No"),
  on_ok() {}
})

class ConfirmDialog {
  constructor(message, options = {}) {
    this.message = message
    this.options = { ...getDefaults(), ...options }
    this.#build()
    this.#bindEvents()
  }

  open() {
    requestAnimationFrame(() => {
      this.dialog.show()
    })
  }

  #build() {
    const width = this.options.size.split("x")[0]
    this.dialog = createHtmlElement(`
      <sl-dialog label="${this.options.title}" style="--width: ${width}px">
        ${this.message}
        <button slot="footer" type="reset" class="secondary mx-1 my-0" autofocus>
          ${this.options.cancel_label}
        </button>
        <button slot="footer" type="submit" class="mx-1 my-0">
          ${this.options.ok_label}
        </button>
      </sl-dialog>
    `)
    document.body.append(this.dialog)
  }

  #bindEvents() {
    this.cancelButton.addEventListener("click", (evt) => {
      evt.preventDefault()
      this.dialog.hide()
    })
    this.okButton.addEventListener("click", (evt) => {
      evt.preventDefault()
      this.options.on_ok()
      this.dialog.hide()
    })
    // Prevent the dialog from closing when the user clicks on the overlay
    this.dialog.addEventListener("sl-request-close", (event) => {
      if (event.detail.source === "overlay") {
        event.preventDefault()
      }
    })
    // Remove the dialog from the DOM after it has been hidden
    this.dialog.addEventListener("sl-after-hide", () => {
      this.dialog.remove()
    })
  }

  get cancelButton() {
    return this.dialog.querySelector("button[type=reset]")
  }

  get okButton() {
    return this.dialog.querySelector("button[type=submit]")
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
  return new Promise((resolve, reject) => {
    const options = {
      on_ok() {
        pleaseWaitOverlay()
        $.ajax({
          url,
          type: "DELETE",
          error(xhr, _status, error) {
            const type = xhr.status === 403 ? "warning" : "error"
            growl(xhr.responseText || error, type)
            reject(error)
          },
          complete(response) {
            pleaseWaitOverlay(false)
            resolve(response)
          }
        })
      }
    }

    openConfirmDialog(opts.message, { ...options, ...opts })
  })
}
