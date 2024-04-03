import { growl } from "alchemy_admin/growler"

class Growl extends HTMLElement {
  connectedCallback() {
    growl(this.getAttribute("message"), this.getAttribute("type") || "notice")
  }
}

customElements.define("alchemy-growl", Growl)
