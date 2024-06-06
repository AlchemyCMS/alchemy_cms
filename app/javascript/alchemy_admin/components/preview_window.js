const MIN_WIDTH = 240

class PreviewWindow extends HTMLIFrameElement {
  #afterLoad
  #reloadIcon

  constructor() {
    super()
    this.addEventListener("load", this)
  }

  handleEvent(evt) {
    if (evt.type === "load") {
      this.#stopSpinner()
      this.#afterLoad?.call(this, evt)
    }
  }

  connectedCallback() {
    let url = this.url

    this.#attachEvents()

    if (window.localStorage.getItem("alchemy-preview-url")) {
      url = window.localStorage.getItem("alchemy-preview-url")
      this.previewUrlSelect.value = url
    }

    this.refresh(url)
  }

  disconnectedCallback() {
    key.unbind("alt+r")
  }

  postMessage(data) {
    this.contentWindow.postMessage(data, "*")
  }

  resize(width) {
    if (width < MIN_WIDTH) {
      width = MIN_WIDTH
    }
    this.style.width = `${width}px`
  }

  refresh(url) {
    this.#startSpinner()

    if (url) {
      this.src = url
    } else {
      this.src = this.url
    }

    return new Promise((resolve) => {
      this.#afterLoad = resolve
    })
  }

  #attachEvents() {
    this.reloadButton?.addEventListener("click", (evt) => {
      evt.preventDefault()
      this.refresh()
    })

    key("alt+r", () => this.refresh())

    // Need to listen with jQuery here because select2 does not emit native events.
    $(this.sizeSelect).on("change", (evt) => {
      const select = evt.target
      const width = select.value

      if (width === "") {
        this.style.width = null
      } else {
        this.resize(width)
      }
    })

    this.previewUrlSelect?.addEventListener("change", (evt) => {
      const url = evt.target.value
      window.localStorage.setItem("alchemy-preview-url", url)
      this.refresh(url)
    })
  }

  #startSpinner() {
    this.#reloadIcon = this.reloadButton.innerHTML
    this.reloadButton.innerHTML = `<alchemy-spinner size="small"></alchemy-spinner>`
  }

  #stopSpinner() {
    this.reloadButton.innerHTML = this.#reloadIcon
  }

  get url() {
    return this.getAttribute("url")
  }

  get sizeSelect() {
    return document.querySelector("select#preview_size")
  }

  get previewUrlSelect() {
    return document.querySelector("select#preview_url")
  }

  get reloadButton() {
    return document.querySelector("#reload_preview_button")
  }
}

customElements.define("alchemy-preview-window", PreviewWindow, {
  extends: "iframe"
})

export function reloadPreview() {
  const previewWindow = document.getElementById("alchemy_preview_window")
  previewWindow.refresh()
}
