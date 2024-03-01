import { get } from "alchemy_admin/utils/ajax"

class AnchorSelect extends HTMLElement {
  #pageId = undefined

  connectedCallback() {
    // get the anchors from the API or from the preview window
    if (this.getAttribute("type") === "preview") {
      this.#fetchAnchorsFromPreview()
    } else {
      this.page = this.getAttribute("page")
    }
  }

  #fetchAnchors() {
    get(Alchemy.routes.api_ingredients_path, { page_id: this.#pageId }).then(
      (result) => {
        this.selectElement.data = result.data.ingredients
          .filter((ingredient) => ingredient.data?.dom_id)
          .map((ingredient) => this.#dataItem(ingredient.data.dom_id))
      }
    )
  }

  #fetchAnchorsFromPreview() {
    // wait a tick to let the browser initialize the inner select component
    setTimeout(() => {
      const frame = document.getElementById("alchemy_preview_window")
      const elements = frame.contentDocument?.querySelectorAll("[id]") || []
      if (elements.length > 0) {
        this.selectElement.data = Array.from(elements).map((element) => {
          return this.#dataItem(element.id)
        })
      }
    })
  }

  #dataItem(hash) {
    return {
      id: hash,
      text: `#${hash}`
    }
  }

  set page(pageId) {
    this.#pageId = pageId
    this.#fetchAnchors()
  }

  get selectElement() {
    return this.querySelector("select")
  }
}

customElements.define("alchemy-anchor-select", AnchorSelect)
