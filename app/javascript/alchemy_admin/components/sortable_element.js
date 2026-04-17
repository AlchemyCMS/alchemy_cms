class SortableElement extends HTMLElement {
  get elementId() {
    return this.getAttribute("element-id")
  }

  get elementName() {
    return this.getAttribute("element-name")
  }

  get elementEditor() {
    return this.querySelector("alchemy-element-editor")
  }
}

customElements.define("alchemy-sortable-element", SortableElement)
