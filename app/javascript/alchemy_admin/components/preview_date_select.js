import { visit } from "@hotwired/turbo"

class PreviewDateSelect extends HTMLElement {
  connectedCallback() {
    this.input.addEventListener("change", () => {
      const url = new URL(window.location)
      if (this.input.value) {
        url.searchParams.set("preview_at", this.input.value)
      } else {
        url.searchParams.delete("preview_at")
      }
      visit(url.toString())
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
