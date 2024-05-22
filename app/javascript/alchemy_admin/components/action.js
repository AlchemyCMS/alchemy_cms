import { reloadPreview } from "alchemy_admin/components/preview_window"

class Action extends HTMLElement {
  constructor() {
    super()
    this.actions = {
      reloadPreview
    }
  }

  connectedCallback() {
    const func = this.actions[this.name]

    if (func) {
      func.call()
    } else {
      console.error(`Unknown Alchemy action: ${this.name}`)
    }
  }

  get name() {
    return this.getAttribute("name")
  }
}

customElements.define("alchemy-action", Action)
