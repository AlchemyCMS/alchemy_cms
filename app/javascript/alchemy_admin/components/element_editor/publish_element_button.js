export class PublishElementButton extends HTMLElement {
  #scheduleButtonVariant

  connectedCallback() {
    this.#scheduleButtonVariant = this.scheduleButton.getAttribute("variant")
    this.publishButton.addEventListener("click", this)
    this.dropdown.addEventListener("sl-show", this)
    this.dropdown.addEventListener("sl-hide", this)
  }

  disconnectedCallback() {
    this.publishButton.removeEventListener("click", this)
    this.dropdown.removeEventListener("sl-show", this)
    this.dropdown.removeEventListener("sl-hide", this)
  }

  handleEvent(event) {
    switch (event.type) {
      case "click":
        this.publishButton.loading = true
        break
      case "sl-show":
        this.scheduleButton.setAttribute("variant", "primary")
        break
      case "sl-hide":
        this.scheduleButton.setAttribute("variant", this.#scheduleButtonVariant)
        break
    }
  }

  get publishButton() {
    return this.querySelector("sl-button[type='submit']")
  }

  get dropdown() {
    return this.querySelector("sl-dropdown")
  }

  get scheduleButton() {
    return this.querySelector("sl-button[slot='trigger']")
  }
}

customElements.define("alchemy-publish-element-button", PublishElementButton)
