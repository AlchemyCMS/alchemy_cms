import { Dialog } from "alchemy_admin/dialog"

export class DialogLink extends HTMLAnchorElement {
  connectedCallback() {
    this.addEventListener("click", this)
  }

  disconnectedCallback() {
    this.removeEventListener("click", this)
  }

  handleEvent(evt) {
    if (!this.disabled) {
      this.openDialog()
    }
    evt.preventDefault()
  }

  openDialog() {
    this.dialog = new Dialog(this.getAttribute("href"), this.dialogOptions)
    this.dialog.open()
  }

  get dialogOptions() {
    const options = this.dataset.dialogOptions
      ? JSON.parse(this.dataset.dialogOptions)
      : {}
    return options
  }

  get disabled() {
    return this.classList.contains("disabled")
  }
}

customElements.define("alchemy-dialog-link", DialogLink, { extends: "a" })
