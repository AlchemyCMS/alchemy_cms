import { Dialog } from "alchemy_admin/dialog"
import { createHtmlElement } from "alchemy_admin/utils/dom_helpers"

export default class ImageOverlay extends Dialog {
  // The picture is rendered in a Turbo frame that replaces its content on every
  // navigation, so the picture elements are looked up on demand instead of being
  // bound once.
  #clickHandler = (e) => {
    if (e.target.closest(".picture-overlay-handle")) {
      e.preventDefault()
      this.dialog.classList.toggle("hide-form")
      return
    }
    if (e.target.closest(".zoomed-picture-background")) {
      e.stopPropagation()
      if (e.target.nodeName === "IMG") {
        return
      }
      this.close()
    }
  }

  #keydownHandler = (e) => {
    if (e.target.nodeName === "INPUT" || e.target.nodeName === "TEXTAREA") {
      return
    }
    switch (e.key) {
      case "ArrowLeft":
        this.previous()
        e.preventDefault()
        break
      case "ArrowRight":
        this.next()
        e.preventDefault()
        break
    }
  }

  init() {
    this.dialog_body.removeEventListener("click", this.#clickHandler)
    this.dialog_body.addEventListener("click", this.#clickHandler)
    this.#initKeyboardNavigation()
    super.init()
  }

  previous() {
    this.dialog_body.querySelector(".previous-picture")?.click()
  }

  next() {
    this.dialog_body.querySelector(".next-picture")?.click()
  }

  close() {
    document.removeEventListener("keydown", this.#keydownHandler)
    return super.close()
  }

  build() {
    this.dialog_container = createHtmlElement(
      '<dialog class="alchemy-image-overlay-container"></dialog>'
    )
    this.dialog = createHtmlElement(
      '<div class="alchemy-image-overlay-dialog"></div>'
    )
    this.dialog_body = createHtmlElement(
      '<div class="alchemy-image-overlay-body"></div>'
    )
    this.close_button =
      createHtmlElement(`<a class="alchemy-image-overlay-close">
      <alchemy-icon name="close" size="xl"></alchemy-icon>
    </a>`)
    this.dialog.append(this.close_button)
    this.dialog.append(this.dialog_body)
    this.dialog_container.append(this.dialog)
    document.body.append(this.dialog_container)
  }

  #initKeyboardNavigation() {
    document.removeEventListener("keydown", this.#keydownHandler)
    document.addEventListener("keydown", this.#keydownHandler)
  }
}
