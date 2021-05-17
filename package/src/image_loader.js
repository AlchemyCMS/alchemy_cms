// Shows spinner while loading images and
// fades the image after its been loaded

const DEFAULT_SPINNER_OPTIONS = { fill: "#fff" }

export default class ImageLoader {
  static init(scope = document, spinnerOptions = DEFAULT_SPINNER_OPTIONS) {
    if (typeof scope === "string") {
      scope = document.querySelector(scope)
    }
    scope.querySelectorAll("img").forEach((image) => {
      const loader = new ImageLoader(image, spinnerOptions)
      loader.load()
    })
  }

  constructor(image, spinnerOptions = DEFAULT_SPINNER_OPTIONS) {
    this.image = image
    this.parent = image.parentNode
    this.spinner = new Alchemy.Spinner("small", spinnerOptions)
    this.bind()
  }

  bind() {
    this.image.addEventListener("load", this.onLoaded.bind(this))
    this.image.addEventListener("error", this.onError.bind(this))
  }

  load(force = false) {
    if (!force && this.image.complete) return

    this.image.classList.add("loading")
    this.spinner.spin(this.image.parentElement)
  }

  onLoaded() {
    this.removeSpinner()
    this.image.classList.remove("loading")
    this.unbind()
  }

  onError() {
    this.removeSpinner()
    this.parent.innerHtml = '<span class="icon warn"></span>'
    this.unbind()
  }

  unbind() {
    this.image.removeEventListener("load", this.onLoaded)
    this.image.removeEventListener("error", this.onError)
  }

  removeSpinner() {
    this.parent.querySelectorAll(".spinner").forEach((spinner) => {
      spinner.remove()
    })
  }
}
