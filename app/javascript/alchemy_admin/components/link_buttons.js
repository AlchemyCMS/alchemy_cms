import "alchemy_admin/components/link_buttons/link_button"
import "alchemy_admin/components/link_buttons/unlink_button"

class LinkButtons extends HTMLElement {
  constructor() {
    super()
    this.addEventListener("alchemy:link", this)
    this.addEventListener("alchemy:unlink", this)
  }

  handleEvent(event) {
    switch (event.type) {
      case "alchemy:link":
        this.setLink(event.detail)
        break
      case "alchemy:unlink":
        this.removeLink()
    }
    event.stopPropagation()
  }

  setLink(data) {
    this.linkUrlField.value = data.url
    this.linkUrlField.dispatchEvent(new Event("change"))
    this.linkTitleField.value = data.title
    this.linkClassField.value = data.type
    this.linkTargetField.value = data.target

    this.unlinkButton.linked = true
    this.elementEditor.setDirty()
  }

  removeLink() {
    this.linkUrlField.value = ""
    this.linkUrlField.dispatchEvent(new Event("change"))
    this.linkTitleField.value = ""
    this.linkClassField.value = ""
    this.linkTargetField.value = ""

    this.linkButton.classList.remove("linked")

    this.elementEditor.setDirty()
  }

  get linkButton() {
    return this.querySelector('[is="alchemy-link-button"]')
  }

  get unlinkButton() {
    return this.querySelector('[is="alchemy-unlink-button"]')
  }

  get ingredientEditor() {
    const ingredientId = this.dataset.ingredientId
    return this.parentElement.closest(`[data-ingredient-id='${ingredientId}']`)
  }

  get elementEditor() {
    return this.closest("alchemy-element-editor")
  }

  get linkUrlField() {
    return this.ingredientEditor.querySelector("[data-link-value]")
  }

  get linkTitleField() {
    return this.ingredientEditor.querySelector("[data-link-title]")
  }

  get linkTargetField() {
    return this.ingredientEditor.querySelector("[data-link-target]")
  }

  get linkClassField() {
    return this.ingredientEditor.querySelector("[data-link-class]")
  }
}

customElements.define("alchemy-link-buttons", LinkButtons)
