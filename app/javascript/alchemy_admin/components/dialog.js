import { AlchemyHTMLElement } from "./alchemy_html_element"

class Dialog extends AlchemyHTMLElement {
  static properties = {
    padding: { default: true },
    size: { default: "400x300" },
    title: { default: "" },
    url: { default: undefined }
  }

  open() {
    this.dialog.showModal()
  }

  async connected() {
    if (this.url) {
      this.fetchedContent = await this.load(this.url)
      this.updateComponent(true)
    }

    // close button
    this.querySelector("header > button").addEventListener("click", () =>
      this.dialog.close()
    )
  }

  /**
   * load content templates from the server
   * @param {string} url
   * @returns {Promise<unknown>|Promise<string>}
   */
  async load(url) {
    const response = await fetch(url, {
      headers: { "X-Requested-With": "XMLHttpRequest" }
    })
    return await response.text()
  }

  render() {
    this.style.setProperty("--dialog-height", this.height + "px")
    this.style.setProperty("--dialog-width", this.width + "px")

    return `
      <dialog class="alchemy-new-dialog">
        <section>
          <header>
            <h3>${this.title}</h3>
            <button aria-label="Close Dialog">
              <i class="icon fas fa-times fa-fw fa-xs"></i>
            </button>
          </header>
          <div class="body ${this.padding ? "padded" : ""}">${this.body}</div>
        </section>
      </dialog>
    `
  }

  get dialog() {
    return this.getElementsByTagName("dialog")[0]
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
