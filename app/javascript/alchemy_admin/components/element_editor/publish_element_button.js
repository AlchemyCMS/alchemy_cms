export class PublishElementButton extends HTMLElement {
  #scheduleButtonVariant

  connectedCallback() {
    this.publishButton = this.querySelector("sl-button[type='submit']")
    this.scheduleButton = this.querySelector("sl-button.schedule-trigger")
    this.scheduleForm = this.closest("alchemy-element-editor").querySelector(
      ".element-schedule-form"
    )
    this.#scheduleButtonVariant = this.scheduleButton.getAttribute("variant")
    this.publishButton.addEventListener("click", this)
    this.scheduleButton.addEventListener("click", this)
  }

  disconnectedCallback() {
    this.publishButton.removeEventListener("click", this)
    this.scheduleButton.removeEventListener("click", this)
  }

  handleEvent(event) {
    switch (event.target) {
      case this.publishButton:
        this.publishButton.loading = true
        break
      case this.scheduleButton:
        if (this.scheduleForm.hidden) {
          this.scheduleForm.hidden = false
          this.scheduleButton.setAttribute("variant", "primary")
          this.scheduleButton.setAttribute("outline", "")
          this.scheduleButton.removeAttribute("outline")
        } else {
          this.scheduleForm.hidden = true
          this.scheduleButton.setAttribute(
            "variant",
            this.#scheduleButtonVariant
          )
          this.scheduleButton.setAttribute("outline", "outline")
        }
        break
    }
  }
}

customElements.define("alchemy-publish-element-button", PublishElementButton)
