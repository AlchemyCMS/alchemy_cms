import { patch } from "alchemy_admin/utils/ajax"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import { growl } from "alchemy_admin/growler"
import { dispatchPageDirtyEvent } from "alchemy_admin/components/element_editor"
import { openDialog } from "alchemy_admin/dialog"

export class PublishElementButton extends HTMLElement {
  connectedCallback() {
    this.publishButton.addEventListener("click", this)
    this.scheduleButton.addEventListener("click", this)
  }

  handleEvent(event) {
    switch (event.target) {
      case this.scheduleButton:
        event.preventDefault()
        openDialog(this.scheduleButton.href, {
          size: "450x260",
          title: this.scheduleButton.closest("sl-tooltip").content
        })
        break
      case this.publishButton:
        this.publishButton.loading = true
        patch(Alchemy.routes.publish_admin_element_path(this.elementId))
          .then((response) => this.afterPublish(response))
          .catch((error) => growl(error.message, "error"))
          .finally(() => (this.publishButton.loading = false))
        break
    }
  }

  afterPublish(response) {
    const data = response.data
    if (data.public) {
      this.elementEditor.published = true
      this.publishButton.setAttribute("variant", "default")
      this.publishButton.setAttribute("outline", "")
      this.hiddenIcon.hidden = true
    } else {
      this.elementEditor.published = false
      this.publishButton.setAttribute("variant", "primary")
      this.publishButton.removeAttribute("outline")
      this.hiddenIcon.hidden = false
    }
    this.publishTooltip.setAttribute("content", data.tooltip)
    if (data.pageHasUnpublishedChanges) {
      dispatchPageDirtyEvent(data)
    }
    reloadPreview()
  }

  get elementEditor() {
    return this.closest("alchemy-element-editor")
  }

  get publishButton() {
    return this.querySelector("sl-button[type='submit']")
  }

  get scheduleButton() {
    return this.querySelector("sl-button[href]")
  }

  get publishTooltip() {
    return this.querySelector("sl-tooltip")
  }

  get elementId() {
    return this.elementEditor.elementId
  }

  get hiddenIcon() {
    return this.elementEditor.querySelector(".element-hidden-icon")
  }
}

customElements.define("alchemy-publish-element-button", PublishElementButton)
