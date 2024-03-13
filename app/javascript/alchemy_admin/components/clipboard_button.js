import "clipboard"

class ClipboardButton extends HTMLElement {
  constructor() {
    super()

    this.innerHTML = `
      <alchemy-icon name="clipboard"></alchemy-icon>
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
