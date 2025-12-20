import { growl } from "alchemy_admin/growler"
import { translate } from "alchemy_admin/i18n"

class PreviewWindow extends HTMLIFrameElement {
  #afterLoad
  #reloadIcon
  #loadTimeout
  #previewReadyHandler

  constructor() {
    super()
    this.addEventListener("load", this)
    this.#previewReadyHandler = this.#handlePreviewReadyMessage.bind(this)
  }

  handleEvent(evt) {
    if (evt.type === "load") {
      this.#clearLoadTimeout()
      this.#stopSpinner()
      this.#afterLoad?.call(this, evt)
    }
  }

  #handlePreviewReadyMessage(event) {
    if (event.data.message === "Alchemy.previewReady") {
      this.#clearLoadTimeout()
      this.#stopSpinner()
      this.#afterLoad?.call(this, event)
    }
  }

  connectedCallback() {
    let url = this.url

    this.#attachEvents()
    window.addEventListener("message", this.#previewReadyHandler)

    if (window.localStorage.getItem("alchemy-preview-url")) {
      url = window.localStorage.getItem("alchemy-preview-url")
      this.previewUrlSelect.value = url
    }

    this.refresh(url)
  }

  disconnectedCallback() {
    key.unbind("alt+r")
    window.removeEventListener("message", this.#previewReadyHandler)
  }

  postMessage(data) {
    this.contentWindow.postMessage(data, "*")
  }

  resize(width) {
    this.style.width = `${width}px`
  }

  refresh(url) {
    this.#startSpinner()

    if (url) {
      this.src = url
    } else {
      this.src = this.url
    }

    // Set 5s timeout as fallback - if iframe doesn't load, stop spinner anyway
    this.#clearLoadTimeout()
    this.#loadTimeout = setTimeout(() => {
      this.#stopSpinner()
      growl(translate("Preview failed to load"), "warning")
    }, 5000)

    return new Promise((resolve) => {
      this.#afterLoad = resolve
    })
  }

  set isDragged(dragged) {
    this.style.transitionProperty = dragged ? "none" : null
    this.style.pointerEvents = dragged ? "none" : null
  }

  #attachEvents() {
    this.reloadButton?.addEventListener("click", (evt) => {
      evt.preventDefault()
      this.refresh()
    })

    key("alt+r", () => this.refresh())

    this.sizeSelect.addEventListener("change", (evt) => {
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
    // Only save the reload icon if we're not already showing a spinner
    if (!this.reloadButton.innerHTML.includes("alchemy-spinner")) {
      this.#reloadIcon = this.reloadButton.innerHTML
    }
    this.reloadButton.innerHTML = `<alchemy-spinner size="small"></alchemy-spinner>`
  }

  #stopSpinner() {
    this.reloadButton.innerHTML = this.#reloadIcon
  }

  #clearLoadTimeout() {
    if (this.#loadTimeout) {
      clearTimeout(this.#loadTimeout)
      this.#loadTimeout = null
    }
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
