import { growl } from "alchemy_admin/growler"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import { confirmToDeleteDialog } from "alchemy_admin/confirm_dialog"

export class DeleteElementButton extends HTMLElement {
  constructor() {
    super()
    this.addEventListener("click", this)
  }

  handleEvent() {
    confirmToDeleteDialog(this.url, { message: this.message }).then(
      (response) => {
        this.#removeElement(response)
      }
    )
  }

  #removeElement(response) {
    const elementEditor = this.closest("alchemy-element-editor")
    const elementId = elementEditor.elementId
    $(`#element_${elementId}`).hide(200, function () {
      growl(response.message)
      reloadPreview()
      if (elementEditor.fixed) {
        Alchemy.FixedElements.removeTab(elementId)
      }
      this.remove()
    })
  }

  get url() {
    return this.getAttribute("href")
  }

  get message() {
    return this.getAttribute("message")
  }
}

customElements.define("alchemy-delete-element-button", DeleteElementButton)
