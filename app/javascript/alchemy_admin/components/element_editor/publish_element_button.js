import { patch } from "alchemy_admin/utils/ajax"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import { growl } from "alchemy_admin/growler"

export class PublishElementButton extends HTMLElement {
  constructor() {
    super()

    this.addEventListener("sl-change", this)
  }

  handleEvent(event) {
    const elementEditor = event.target.closest("alchemy-element-editor")
    if (elementEditor === this.elementEditor) {
      patch(Alchemy.routes.publish_admin_element_path(this.elementId))
        .then((response) => {
          this.elementEditor.published = response.data.public
          this.tooltip.setAttribute("content", response.data.label)
          reloadPreview()
        })
        .catch((error) => growl(error.message, "error"))
    }
  }

  get elementEditor() {
    return this.closest("alchemy-element-editor")
  }

  get tooltip() {
    return this.closest("sl-tooltip")
  }

  get elementId() {
    return this.elementEditor.elementId
  }
}

customElements.define("alchemy-publish-element-button", PublishElementButton)
