import { patch } from "alchemy_admin/utils/ajax"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import { growl } from "alchemy_admin/growler"
import { dispatchPageDirtyEvent } from "alchemy_admin/components/element_editor"
import { openDialog } from "alchemy_admin/dialog"

export class PublishElementButton extends HTMLElement {
  constructor() {
    super()

    this.button.addEventListener("click", this)
    this.scheduleButton.addEventListener("click", this)
  }

  handleEvent(event) {
    const elementEditor = event.target.closest("alchemy-element-editor")

    if (event.target === this.scheduleButton) {
      // Open schedule dialog
      event.preventDefault()
      openDialog(this.scheduleButton.href, {
        size: "450x200",
        title: "Schedule Element Visibility"
      })
    } else if (elementEditor === this.elementEditor) {
      this.button.loading = true
      patch(Alchemy.routes.publish_admin_element_path(this.elementId))
        .then((response) => {
          const data = response.data
          this.elementEditor.published = data.public
          this.button.setAttribute(
            "variant",
            data.public ? "default" : "primary"
          )
          if (data.public) {
            this.button.setAttribute("outline", true)
          } else {
            this.button.removeAttribute("outline")
          }
          this.tooltip.setAttribute("content", data.tooltip)
          reloadPreview()
          if (data.pageHasUnpublishedChanges) {
            dispatchPageDirtyEvent(data)
          }
        })
        .catch((error) => growl(error.message, "error"))
        .finally(() => {
          this.button.loading = false
        })
    }
  }

  get elementEditor() {
    return this.closest("alchemy-element-editor")
  }

  get button() {
    return this.querySelector("sl-button")
  }

  get scheduleButton() {
    return this.querySelector("sl-button[href]")
  }

  get buttonLabel() {
    return this.querySelector("sl-button span")
  }

  get tooltip() {
    return this.querySelector("sl-tooltip")
  }

  get elementId() {
    return this.elementEditor.elementId
  }
}

customElements.define("alchemy-publish-element-button", PublishElementButton)
