import { createHtmlElement } from "alchemy_admin/utils/dom_helpers"

export default class Spinner {
  constructor(size, color = "currentColor") {
    this.size = size
    this.color = color
    this.spinner = undefined
  }

  /**
   * @returns {HTMLElement|undefined}
   */
  get el() {
    return this.spinner
  }
  /**
   * @param {HTMLElement|undefined} parent
   */
  spin(parent) {
    if (typeof parent === "undefined") {
      parent = document.body
    }
    this.spinner = createHtmlElement(
      `<alchemy-spinner size="${this.size}" color="${this.color}"></alchemy-spinner>`
    )
    parent.append(this.spinner)
    return this
  }

  stop() {
    if (this.spinner) {
      this.spinner.remove()
      this.spinner = undefined
    }
  }
}
