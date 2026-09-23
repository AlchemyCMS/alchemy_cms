import { checkPageDirtyness } from "alchemy_admin/dirty"

class UnlockPageButton extends HTMLElement {
  connectedCallback() {
    this.addEventListener("submit", this)
  }

  disconnectedCallback() {
    this.removeEventListener("submit", this)
  }

  handleEvent(event) {
    if (!checkPageDirtyness(event.target)) {
      event.preventDefault()
    }
  }
}

customElements.define("alchemy-unlock-page-button", UnlockPageButton)
