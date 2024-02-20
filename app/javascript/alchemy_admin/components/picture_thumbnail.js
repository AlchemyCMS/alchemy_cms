import Spinner from "alchemy_admin/spinner"

const MAX_RETRIES = 25
const WAIT_TIME = 1000
const OFFSET_INCREMENT = 100

class PictureThumbnail extends HTMLElement {
  #retries = MAX_RETRIES
  #retryOffset = 0
  #started = false
  #retryTimeout = null

  constructor() {
    super()
    this.classList.add("thumbnail_background")
    this.spinner = new Spinner(this.spinnerSize)
  }

  connectedCallback() {
    if (this.image && !this.image.complete) {
      this.start()
    }
  }

  disconnectedCallback() {
    this.reset()
  }

  handleEvent(event) {
    switch (event.type) {
      case "load":
        this.showImage()
        break
      case "error":
        this.retry()
        break
    }
  }

  start() {
    if (this.#started) return

    this.#started = true
    this.image.classList.add("hidden")
    this.spinner.spin(this)
    this.image.addEventListener("load", this)
    this.image.addEventListener("error", this)
  }

  showImage() {
    this.#started = false
    this.image.classList.remove("hidden")
    this.classList.add("loaded")
    this.spinner.stop()
    this.reset()
  }

  retry() {
    if (this.#retries > 0) {
      this.#retries--
      this.#retryTimeout = setTimeout(() => {
        this.image.src = this.image.src
      }, WAIT_TIME + this.#retryOffset)
      this.#retryOffset += OFFSET_INCREMENT
    } else {
      this.showError()
    }
  }

  showError() {
    const message = `Could not load "${this.image.src}"`
    console.error(message)
    this.innerHTML = `<span class="icon error ri-file-damage-line" title="${message}" />`
    this.reset()
  }

  reset() {
    this.#started = false
    this.#retries = MAX_RETRIES

    if (this.#retryTimeout) {
      clearTimeout(this.#retryTimeout)
      this.#retryTimeout = null
    }

    if (this.image) {
      this.image.removeEventListener("load", this)
      this.image.removeEventListener("error", this)
    }
  }

  get spinnerSize() {
    return this.getAttribute("spinner-size") || "small"
  }

  get image() {
    return this.querySelector("img")
  }
}

customElements.define("alchemy-picture-thumbnail", PictureThumbnail)
