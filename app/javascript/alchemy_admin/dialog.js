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
    this.#openDialog()
    this.#select2Handling()

    // bind the current class instance to the DOM - element
    // this should be an intermediate solution
    // the main goal, is to close the dialog with the turbo:submit-end - event
    this.#dialogComponent.dialogClassInstance = this

    // the dialog is closing with the overlay, esc - key, or close - button
    // the reject - callback will be fired, because the user decided to close the
    // dialog without saving anything
    this.#dialogComponent.addEventListener("sl-after-hide", () => {
      this.#removeDialog()
      this.#onReject()
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
   * create and append the dialog container to the DOM
   */
  #build() {
    this.#dialogComponent = createHtmlElement(`
      <sl-dialog label="${this.title}" style="${this.styles}">
        <alchemy-remote-partial url="${this.url}"></alchemy-remote-partial>
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
    this.#dialogComponent.remove()
    this.#isOpen = false
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
