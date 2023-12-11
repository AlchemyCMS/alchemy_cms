import { patch } from "alchemy_admin/utils/ajax"

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
          this.label.innerText = response.data.label
          Alchemy.reloadPreview()
        })
        .catch((error) => Alchemy.growl(error.message, "error"))
    }
  }

  get elementEditor() {
    return this.closest("alchemy-element-editor")
  }

  get label() {
    return this.querySelector("label")
  }

  get elementId() {
    return this.elementEditor.elementId
  }
}

customElements.define("alchemy-publish-element-button", PublishElementButton)
