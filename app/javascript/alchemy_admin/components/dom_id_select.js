import { get } from "alchemy_admin/utils/ajax"
import { translate } from "alchemy_admin/i18n"

class DomIdSelect extends HTMLElement {
  dataItem(hash) {
    return {
      id: `#${hash}`,
      text: `#${hash}`
    }
  }

  get selectElement() {
    return this.querySelector('select[is="alchemy-select"]')
  }
}

class DomIdApiSelect extends DomIdSelect {
  #pageId = undefined

  connectedCallback() {
    this.page = this.getAttribute("page")
  }

  async #fetchDomIds() {
    const result = await get(Alchemy.routes.api_ingredients_path, {
      page_id: this.#pageId
    })
    const options = result.data.ingredients
      .filter((ingredient) => ingredient.data?.dom_id)
      .map((ingredient) => this.dataItem(ingredient.data.dom_id))
    const prompt =
      options.length > 0 ? translate("None") : translate("No anchors found")

    this.selectElement.setOptions(options, prompt)
    this.selectElement.enable()
  }

  #reset() {
    // wait a tick to initialize the alchemy-select
    requestAnimationFrame(() => {
      this.selectElement.disable()
      this.selectElement.setOptions([], translate("Select a page first"))
    })
  }

  set page(pageId) {
    this.#pageId = pageId
    pageId ? this.#fetchDomIds() : this.#reset()
  }
}

class DomIdPreviewSelect extends DomIdSelect {
  connectedCallback() {
    // wait a tick to let the browser initialize the inner select component
    requestAnimationFrame(() => {
      const frame = document.getElementById("alchemy_preview_window")
      const elements = frame.contentDocument?.querySelectorAll("[id]") || []
      if (elements.length > 0) {
        const options = Array.from(elements).map((element) => {
          return this.dataItem(element.id)
        })
        this.selectElement.setOptions(options, translate("None"))
      }
    })
  }
}

customElements.define("alchemy-dom-id-api-select", DomIdApiSelect)
customElements.define("alchemy-dom-id-preview-select", DomIdPreviewSelect)
