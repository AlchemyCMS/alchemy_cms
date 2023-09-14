import { AlchemyHTMLElement } from "./alchemy_html_element"

export class Dialog extends AlchemyHTMLElement {
  static properties = {
    padding: { default: true },
    size: { default: "400x300" },
    title: { default: "" },
    url: { default: undefined }
  }

  /**
   * Public method to open the dialog
   */
  open() {
    this.dialogElement.showModal()
  }

  /**
   * public method to close (and destroy) the dialog
   */
  close() {
    // close the dialog element
    this.dialogElement.close()
    document.dispatchEvent(new CustomEvent("DialogClose.Alchemy"))
  }

  connected() {
    // load body content if a url is available
    if (this.url) {
      this.load(this.url).then((fetchedContent) => {
        this.bodyElement.innerHTML = fetchedContent
      })
    }
  }

  updated() {
    // close button
    this.querySelector("header > button").addEventListener("click", () =>
      this.close()
    )

    // remove the whole dialog component from DOM, if the dialog was closed (via close button or ESC - key)
    this.dialogElement.addEventListener("close", () => this.remove())

    // trigger an event in page publication fields
    document.dispatchEvent(
      new CustomEvent("DialogReady.Alchemy", {
        detail: { body: this.bodyElement }
      })
    )

    Alchemy.GUI.init(this.bodyElement)
  }

  /**
   * load content templates from the server
   * @param {string} url
   * @returns {Promise<string>}
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
          <div class="body ${this.padding ? "padded" : ""}">${
            this.content
          }</div>
        </section>
      </dialog>
    `
  }

  get dialogElement() {
    return this.getElementsByTagName("dialog")[0]
  }

  get bodyElement() {
    return this.getElementsByClassName("body")[0]
  }

  get content() {
    return this.url
      ? `<alchemy-spinner></alchemy-spinner>`
      : this.initialContent
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
