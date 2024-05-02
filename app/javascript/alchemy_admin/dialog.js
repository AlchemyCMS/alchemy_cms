import { createHtmlElement } from "alchemy_admin/utils/dom_helpers"

export class Dialog {
  #dialogComponent
  #isOpen = false
  #onReject
  #onResolve

  /**
   * @param {string} url
   * @param {object} options
   */
  constructor(url, options = {}) {
    this.url = url
    this.options = { title: "", size: "300x400", padding: true, ...options }
  }

  /**
   * load the content of given url and than open the dialog
   * @returns {Promise<unknown>}
   */
  open() {
    this.#build()
    // Show the dialog with the spinner after a small delay.
    // in most cases the content of the dialog is already available and the spinner is not flashing
    setTimeout(() => this.#openDialog, 300)

    this.#loadContent().then((content) => {
      // create the dialog markup and show the dialog
      this.#dialogComponent.innerHTML = content
      this.#select2Handling()
      this.#openDialog()

      // bind the current class instance to the DOM - element
      // this should be an intermediate solution
      // the main goal, is to close the dialog with the turbo:submit-end - event
      this.#dialogComponent.dialogClassInstance = this

      // the dialog is closing with the overlay, esc - key, or close - button
      // the reject - callback will be fired, because the user decided to close the
      // dialog without saving anything
      this.#dialogComponent.addEventListener("sl-request-close", () => {
        this.#removeDialog()
        this.#onReject()
      })
    })

    return new Promise((resolve, reject) => {
      this.#onResolve = resolve
      this.#onReject = reject
    })
  }

  /**
   * hide and remove dialog
   * the open - promise will be resolved
   * @param {function|undefined} callback
   */
  onSubmitSuccess(callback = undefined) {
    this.#dialogComponent.hide().then(() => {
      this.#removeDialog()
      this.#onResolve()

      // add possibility to provide a callback
      // this is a intermediate solution until the old Alchemy dialog is gone
      if (callback) {
        callback()
      }
    })
  }

  /**
   * load content of the given url
   * @returns {Promise<string>}
   */
  async #loadContent() {
    const response = await fetch(this.url, {
      headers: { "X-Requested-With": "XMLHttpRequest" }
    })
    return await response.text()
  }

  /**
   * create and append the dialog container to the DOM
   */
  #build() {
    this.#dialogComponent = createHtmlElement(`
      <sl-dialog label="${this.title}" style="${this.styles}">
        <alchemy-spinner size="medium"></alchemy-spinner>
      </sl-dialog>
    `)
    document.body.append(this.#dialogComponent)
  }

  /**
   * opens the dialog
   * the dialog is only opening once
   */
  #openDialog() {
    if (!this.#isOpen) {
      this.#dialogComponent.show()
      this.#isOpen = true
    }
  }

  /**
   * remove the dialog from dom
   */
  #removeDialog() {
    this.#dialogComponent.addEventListener("sl-after-hide", () => {
      this.#dialogComponent.remove()
      this.#isOpen = false
    })
  }

  /**
   * activate and deactivate the focus trap of the sl-dialog, if a select2 - component is opening
   */
  #select2Handling() {
    $(this.#dialogComponent)
      .on("select2-open", (evt) => {
        this.#dialogComponent.modal.activateExternal()
      })
      .on("select2-close", (evt) => {
        this.#dialogComponent.modal.deactivateExternal()
      })
  }

  /**
   * provide the custom properties for the dialog settings
   * @returns {string}
   */
  get styles() {
    const sizes = this.options.size.split("x")
    let styles = `--width: ${sizes[0]}px; --dialog-min-height: ${sizes[1]}px;`
    if (!this.options.padding) {
      styles += " --body-spacing: 0;"
    }
    return styles
  }

  /**
   * get the title of the dialog
   * @returns {string}
   */
  get title() {
    return this.options.title
  }
}
