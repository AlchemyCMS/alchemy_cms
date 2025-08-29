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
      <wa-dialog label="${this.options.title}" style="--width: ${width}px">
        ${this.message}
        <button slot="footer" type="reset" class="secondary mx-1 my-0" autofocus>
          ${this.options.cancel_label}
        </button>
        <button slot="footer" type="submit" class="mx-1 my-0">
          ${this.options.ok_label}
        </button>
      </wa-dialog>
    `)
    document.body.append(this.dialog)
  }

  #bindEvents() {
    this.cancelButton.addEventListener("click", (evt) => {
      evt.preventDefault()
      this.options.on_cancel()
      this.dialog.hide()
    })
    this.okButton.addEventListener("click", (evt) => {
      evt.preventDefault()
      this.options.on_ok()
      this.dialog.hide()
    })
    // Prevent the dialog from closing when the user clicks on the overlay
    this.dialog.addEventListener("wa-request-close", (event) => {
      if (event.detail.source === "overlay") {
        this.options.on_cancel()
        event.preventDefault()
      }
    })
    // Remove the dialog from the DOM after it has been hidden
    this.dialog.addEventListener("wa-after-hide", () => {
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

/* Opens a confirm dialog
 *
 * @param {string} message - The message that will be displayed to the user
 * @param {Object} [options={}] - Configuration options for the dialog
 * @param {string} [options.title="Please confirm"] - The title of the overlay window
 * @param {string} [options.cancel_label="No"] - The label of the cancel button
 * @param {string} [options.ok_label="Yes"] - The label of the ok button
 *
 * @returns {Promise<void>} A promise that resolves to true when the OK button is clicked and
 *   resolves to false when the cancel button is clicked. Works as confirm dialog replacement
 *   for Turbo.confirm.
 */
export function openConfirmDialog(message, options = {}) {
  return new Promise((resolve) => {
    const dialog = new ConfirmDialog(message, {
      ...options,
      on_ok() {
        resolve(true)
      },
      on_cancel() {
        resolve(false)
      }
    })
    dialog.open()
  })
}
