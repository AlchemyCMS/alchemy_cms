import { removeTab } from "alchemy_admin/fixed_elements"
import { growl } from "alchemy_admin/growler"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import { openConfirmDialog } from "alchemy_admin/confirm_dialog"

export class DeleteElementButton extends HTMLElement {
  constructor() {
    super()
    this.addEventListener("click", this)
  }

  async handleEvent() {
    const confirmed = await openConfirmDialog(this.message)
    if (confirmed) {
      const response = await fetch(this.url, { method: "DELETE" })
      this.#removeElement(await response.json())
    }
  }

  #removeElement(response) {
    const elementEditor = this.closest("alchemy-element-editor")
    elementEditor.addEventListener("transitionend", () => {
      if (elementEditor.fixed) {
        removeTab(elementEditor.elementId)
      }
      elementEditor.remove()
    })
    elementEditor.classList.add("dismiss")
    growl(response.message)
    reloadPreview()
  }

  get url() {
    return this.getAttribute("href")
  }

  get message() {
    return this.getAttribute("message")
  }
}

customElements.define("alchemy-delete-element-button", DeleteElementButton)
