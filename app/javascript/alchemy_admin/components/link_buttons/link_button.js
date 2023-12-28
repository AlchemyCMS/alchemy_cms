class LinkButton extends HTMLButtonElement {
  constructor() {
    super()
    this.addEventListener("click", this)
    this.classList.add("icon_button")
    // Prevent accidental form submits if this component is wrapped inside a form
    this.setAttribute("type", "button")
    this.innerHTML = '<i class="icon ri-link-m ri-fw"></i>'
  }

  handleEvent(event) {
    const dialog = new Alchemy.LinkDialog(this)
    dialog.open()
    event.preventDefault()
  }

  setLink(url, title, target, type) {
    this.classList.add("linked")
    this.dispatchEvent(
      new CustomEvent("alchemy:link", {
        bubbles: true,
        detail: { url, title, target, type }
      })
    )
  }

  get linkUrl() {
    return this.linkButtons.linkUrlField.value
  }

  get linkTitle() {
    return this.linkButtons.linkTitleField.value
  }

  get linkTarget() {
    return this.linkButtons.linkTargetField.value
  }

  get linkClass() {
    return this.linkButtons.linkClassField.value
  }

  get linkButtons() {
    return this.closest("alchemy-link-buttons")
  }
}

customElements.define("alchemy-link-button", LinkButton, { extends: "button" })
