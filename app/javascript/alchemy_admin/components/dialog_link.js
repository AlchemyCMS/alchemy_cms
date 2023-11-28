export const DEFAULTS = {
  header_height: 36,
  size: "400x300",
  padding: true,
  title: "",
  modal: true,
  overflow: "visible",
  draggable: true,
  ready: () => {},
  closed: () => {}
}

export class DialogLink extends HTMLAnchorElement {
  connectedCallback() {
    this.addEventListener("click", (evt) => {
      if (!this.disabled) {
        this.openDialog()
      }
      evt.preventDefault()
    })
  }

  openDialog() {
    this.dialog = new Alchemy.Dialog(
      this.getAttribute("href"),
      this.dialogOptions
    )
    this.dialog.open()
  }

  get dialogOptions() {
    const options = this.dataset.dialogOptions
      ? JSON.parse(this.dataset.dialogOptions)
      : {}
    return {
      ...DEFAULTS,
      ...options
    }
  }

  get disabled() {
    return this.classList.contains("disabled")
  }
}

customElements.define("alchemy-dialog-link", DialogLink, { extends: "a" })
