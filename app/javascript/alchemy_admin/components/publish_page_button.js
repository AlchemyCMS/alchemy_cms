import { checkPageDirtyness } from "alchemy_admin/dirty"

class PublishPageButton extends HTMLElement {
  connectedCallback() {
    this.addEventListener("submit", this)
    document.addEventListener("alchemy:page-dirty", this)
  }

  disconnectedCallback() {
    this.removeEventListener("submit", this)
    document.removeEventListener("alchemy:page-dirty", this)
  }

  handleEvent(event) {
    switch (event.type) {
      case "alchemy:page-dirty":
        this.markDirty(event.detail)
        break
      case "submit":
        if (checkPageDirtyness(event.target)) {
          this.button.loading = true
        } else {
          event.preventDefault()
        }
        break
    }
  }

  markDirty(detail) {
    this.button.variant = "primary"
    this.button.disabled = false
    this.tooltip.content = detail.tooltip
  }

  get button() {
    return this.querySelector("sl-button")
  }

  get tooltip() {
    return this.querySelector("sl-tooltip")
  }
}

customElements.define("alchemy-publish-page-button", PublishPageButton)
