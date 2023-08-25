import { createHtmlElement, wrap } from "alchemy_admin/utils/dom_helpers"

/**
 * show tooltips on fixed inputs
 */
class Tooltip extends HTMLInputElement {
  constructor() {
    super()

    const text = this.dataset.tooltip
    wrap(this, createHtmlElement('<div class="with-hint" />'))
    this.after(createHtmlElement(`<span class="hint-bubble">${text}</span>`))
  }
}

customElements.define("alchemy-tooltip", Tooltip, { extends: "input" })
