class LinkButton extends HTMLButtonElement {
  constructor() {
    super()
    this.addEventListener("click", this)
    this.classList.add("icon_button")
    // Prevent accidental form submits if this component is wrapped inside a form
    this.setAttribute("type", "button")
    this.innerHTML = '<alchemy-icon name="link" icon-style="m"></alchemy-icon>'
  }

  handleEvent(event) {
    const dialog = new Alchemy.LinkDialog({
      url: this.linkUrl,
      title: this.linkTitle,
      target: this.linkTarget,
      type: this.linkClass
    })
    dialog.open().then((link) => this.setLink(link))
    event.preventDefault()
  }

  setLink(link) {
    if (link.url === "") {
      this.classList.remove("linked")
      this.dispatchEvent(new CustomEvent("alchemy:unlink", { bubbles: true }))
    } else {
      this.classList.add("linked")
      this.dispatchEvent(
        new CustomEvent("alchemy:link", {
          bubbles: true,
          detail: link
        })
      )
    }
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
