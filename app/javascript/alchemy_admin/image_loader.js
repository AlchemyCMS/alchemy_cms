// Shows spinner while loading images and
// fades the image after its been loaded

import Spinner from "alchemy_admin/spinner"

export default class ImageLoader {
  static init(scope = document) {
    if (typeof scope === "string") {
      scope = document.querySelector(scope)
    }
    scope.querySelectorAll("img").forEach((image) => {
      const loader = new ImageLoader(image)
      loader.load()
    })
  }

  constructor(image) {
    this.image = image
    this.parent = image.parentNode
    this.spinner = new Spinner("small")
    this.bind()
  }

  bind() {
    this.image.addEventListener("load", this.onLoaded.bind(this))
    this.image.addEventListener("error", this.onError.bind(this))
  }

  load(force = false) {
    if (!force && this.image.complete) return

    this.image.classList.add("loading")
    this.spinner.spin(this.parent)
  }

  onLoaded() {
    this.spinner.stop()
    this.image.classList.remove("loading")
    this.unbind()
  }

  onError(evt) {
    const message = `Could not load ${this.image.src}`
    this.spinner.stop()
    this.parent.innerHTML = `<alchemy-icon name="alert" class="error" title="${message}" />`
    console.error(message, evt)
    this.unbind()
  }

  unbind() {
    this.image.removeEventListener("load", this.onLoaded)
    this.image.removeEventListener("error", this.onError)
  }
}
