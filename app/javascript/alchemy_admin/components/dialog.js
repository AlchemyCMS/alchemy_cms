import { AlchemyHTMLElement } from "./alchemy_html_element"

class Dialog extends AlchemyHTMLElement {
  static properties = {
    overflow: { default: "visible" },
    padding: { default: true },
    open: { default: false },
    size: { default: "400x300" },
    title: { default: "" },
    url: { default: undefined }
  }

  async connected() {
    this.fetchedContent = await this.load()

    if (this.fetchedContent) {
      this.updateComponent(true)
    }
    this.initializeDialog()

    setTimeout(() => this.dialog.showModal(), 500)
  }

  initializeDialog() {
    this.dialog = this.getElementsByTagName("dialog")[0]
    this.closeButton = this.querySelector("header > button")

    // close on backdrop
    this.dialog.addEventListener("click", (event) => {
      const rect = this.dialog.getBoundingClientRect()
      const isInDialog =
        rect.top <= event.clientY &&
        event.clientY <= rect.top + rect.height &&
        rect.left <= event.clientX &&
        event.clientX <= rect.left + rect.width

      if (!isInDialog) {
        this.dialog.close()
      }
    })

    // close on close button
    this.closeButton.addEventListener("click", () => this.dialog.close())
  }

  async load() {
    if (!this.url) {
      return new Promise((resolve) => resolve(undefined))
    }

    const response = await fetch(this.url, {
      headers: { "X-Requested-With": "XMLHttpRequest" }
    })
    return await response.text()
  }

  render() {
    this.style.setProperty("--dialog-height", this.height + "px")
    this.style.setProperty("--dialog-width", this.width + "px")
    this.style.setProperty("--dialog-overflow", this.overflow)
    this.style.setProperty(
      "--dialog-body-overflow",
      this.overflow === "hidden" ? "auto" : "visible"
    )

    return `
      <dialog class="alchemy-new-dialog">
        <section>
          <header>
            <h3>${this.title}</h3>
            <button aria-label="Close Dialog">
              <i class="icon fas fa-times fa-fw fa-xs"></i>
            </button>
          </header>
          <div class="body">${this.body}</div>
        </section>
      </dialog>
    `
  }

  get body() {
    if (this.fetchedContent) {
      return this.fetchedContent
    }
    return this.slotedContent
  }

  get height() {
    const maxHeight = this.dimension[1]
    const maxInnerHeight = window.innerHeight - 52 // Default Padding 16px - Header Height 36px

    return maxHeight < maxInnerHeight ? maxHeight : maxInnerHeight
  }

  get width() {
    const maxWidth = this.dimension[0]
    const maxInnerWidth = window.innerWidth - 16 // Default Padding 16px

    return maxWidth < maxInnerWidth ? maxWidth : maxInnerWidth
  }

  get dimension() {
    if (typeof this.size === "undefined" || this.size === "fullscreen") {
      return [undefined, undefined]
    }
    const size = this.size.split("x")
    return [parseInt(size[0], 10), parseInt(size[1], 10)]
  }
}

customElements.define("alchemy-dialog", Dialog)
