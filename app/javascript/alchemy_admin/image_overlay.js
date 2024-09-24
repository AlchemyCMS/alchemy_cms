import ImageLoader from "alchemy_admin/image_loader"
import { Dialog } from "alchemy_admin/dialog"

export default class ImageOverlay extends Dialog {
  constructor(url, options = {}) {
    super(url, options)
  }

  init() {
    ImageLoader.init(this.dialog_body[0])
    $(".zoomed-picture-background").on("click", (e) => {
      e.stopPropagation()
      if (e.target.nodeName === "IMG") {
        return
      }
      this.close()
      return false
    })
    $(".picture-overlay-handle").on("click", (e) => {
      this.dialog.toggleClass("hide-form")
      return false
    })
    this.$previous = $(".previous-picture")
    this.$next = $(".next-picture")
    this.#initKeyboardNavigation()
    super.init()
  }

  previous() {
    if (this.$previous[0] != null) {
      this.$previous[0].click()
    }
  }

  next() {
    if (this.$next[0] != null) {
      this.$next[0].click()
    }
  }

  build() {
    this.dialog_container = $('<div class="alchemy-image-overlay-container" />')
    this.dialog = $('<div class="alchemy-image-overlay-dialog" />')
    this.dialog_body = $('<div class="alchemy-image-overlay-body" />')
    this.close_button = $(`<a class="alchemy-image-overlay-close">
      <alchemy-icon name="close" size="xl"></alchemy-icon>
    </a>`)
    this.dialog.append(this.close_button)
    this.dialog.append(this.dialog_body)
    this.dialog_container.append(this.dialog)
    this.overlay = $('<div class="alchemy-image-overlay" />')
    this.$body.append(this.overlay)
    this.$body.append(this.dialog_container)
  }

  #initKeyboardNavigation() {
    this.$document.keydown((e) => {
      if (e.target.nodeName === "INPUT" || e.target.nodeName === "TEXTAREA") {
        return true
      }
      switch (e.which) {
        case 37:
          this.previous()
          return false
        case 39:
          this.next()
          return false
        default:
          return true
      }
    })
  }
}
