class PreviewDateSelect extends HTMLElement {
  connectedCallback() {
    this.input.addEventListener("change", () => {
      this.dispatchEvent(
        new CustomEvent("preview-at-changed", {
          bubbles: true,
          detail: { previewAt: this.input.value }
        })
      )
    })
  }

  clear() {
    this.input.value = ""
  }

  get input() {
    return this.querySelector("input")
  }
}

customElements.define("alchemy-preview-date-select", PreviewDateSelect)
