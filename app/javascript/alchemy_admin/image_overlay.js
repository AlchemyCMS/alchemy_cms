import { Dialog } from "alchemy_admin/dialog"
import { createHtmlElement } from "alchemy_admin/utils/dom_helpers"

export default class ImageOverlay extends Dialog {
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
    this.dialog_body
      .querySelector(".zoomed-picture-background")
      ?.addEventListener("click", (e) => {
        e.stopPropagation()
        if (e.target.nodeName === "IMG") {
          return
        }
        this.close()
      })
    this.dialog_body
      .querySelector(".picture-overlay-handle")
      ?.addEventListener("click", (e) => {
        e.preventDefault()
        this.dialog.classList.toggle("hide-form")
      })
    this.previous_button = this.dialog_body.querySelector(".previous-picture")
    this.next_button = this.dialog_body.querySelector(".next-picture")
    this.#initKeyboardNavigation()
    super.init()
  }

  previous() {
    if (this.previous_button != null) {
      this.previous_button.click()
    }
  }

  next() {
    if (this.next_button != null) {
      this.next_button.click()
    }
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
    // init() runs again after each remote navigation, so make sure the
    // handler is only registered once.
    document.removeEventListener("keydown", this.#keydownHandler)
    document.addEventListener("keydown", this.#keydownHandler)
  }
}
