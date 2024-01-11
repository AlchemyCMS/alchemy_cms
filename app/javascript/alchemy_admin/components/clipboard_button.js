import "clipboard"

class ClipboardButton extends HTMLElement {
  constructor() {
    super()

    this.innerHTML = `
      <i class="icon ri-clipboard-line ri-fw"></i>
    `

    this.clipboard = new ClipboardJS(this, {
      text: () => {
        return this.getAttribute("content")
      }
    })

    this.clipboard.on("success", () => {
      Alchemy.growl(this.getAttribute("success-text"))
    })
  }

  disconnectedCallback() {
    this.clipboard.destroy()
  }
}

customElements.define("alchemy-clipboard-button", ClipboardButton)
