import { growl } from "alchemy_admin/growler"

class Growl extends HTMLElement {
  connectedCallback() {
    growl(this.message, this.getAttribute("type") || "notice")
  }

  get message() {
    return this.getAttribute("message") || this.innerHTML
  }
}

customElements.define("alchemy-growl", Growl)
