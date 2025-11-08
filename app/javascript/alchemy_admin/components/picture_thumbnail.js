// Shows spinner while loading images and
// fades the image after its been loaded

import Spinner from "alchemy_admin/spinner"

export default class PictureThumbnail extends HTMLElement {
  constructor() {
    super()

    this.classList.add("thumbnail_background")
    this.spinner = new Spinner("small")

    if (this.src) {
      this.start()
    }
  }

  handleEvent(evt) {
    switch (evt.type) {
      case "load":
        this.#onLoaded()
        break
      case "error":
        this.#onError(evt)
        break
      default:
        break
    }
  }

  connectedCallback() {
    if (this.image) {
      this.appendChild(this.image)
    }
  }

  disconnectedCallback() {
    this.image?.removeEventListener("load", this)
    this.image?.removeEventListener("error", this)
    this.stop()
  }

  createImage(src = this.src, alt = this.name) {
    this.image = new Image()
    this.image.src = src
    if (alt) {
      this.image.alt = alt
    }
    this.image.loading = "lazy"
  }

  start(src) {
    this.createImage(src)
    this.image.addEventListener("load", this)
    this.image.addEventListener("error", this)
    this.load()
  }

  load() {
    if (this.image?.complete) {
      return
    }
    this.setAttribute("loading", "loading")
    this.innerHTML = ""
    this.spinner.spin(this)
  }

  stop() {
    this.classList.remove("loading")
    this.spinner.stop()
  }

  #onLoaded() {
    this.spinner.stop()
    this.removeAttribute("loading")
  }

  #onError(evt) {
    const message = `Could not load ${this.image.src}`
    this.spinner.stop()
    this.innerHTML = `
      <wa-tooltip content="${message}">
        <alchemy-icon name="alert" class="error"></alchemy-icon>
      </wa-tooltip>
    `
    console.error(message, evt)
  }

  set loading(value) {
    value ? this.load() : this.stop()
  }

  set src(src) {
    this.start(src)
    this.replaceChildren(this.image)
  }

  get name() {
    return this.getAttribute("name")
  }

  get src() {
    return this.getAttribute("src")
  }
}

customElements.define("alchemy-picture-thumbnail", PictureThumbnail)
