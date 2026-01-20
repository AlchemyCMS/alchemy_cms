class PublishPageButton extends HTMLElement {
  constructor() {
    super()
    this.addEventListener("submit", this)
  }

  connectedCallback() {
    document.addEventListener("alchemy:page-dirty", this)
  }

  disconnectedCallback() {
    document.removeEventListener("alchemy:page-dirty", this)
  }

  handleEvent(event) {
    switch (event.type) {
      case "alchemy:page-dirty":
        this.markDirty(event.detail)
        break
      case "submit":
        this.button.loading = true
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
