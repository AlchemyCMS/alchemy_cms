import { DialogLink } from "alchemy_admin/components/dialog_link"
import ImageOverlay from "alchemy_admin/image_overlay"

// Opens the picture in a full screen image overlay instead of navigating to it
export class ImageOverlayLink extends DialogLink {
  openDialog() {
    this.dialog = new ImageOverlay(this.href, { padding: false })
    this.dialog.open()
  }
}

customElements.define("alchemy-image-overlay-link", ImageOverlayLink, {
  extends: "a"
})
