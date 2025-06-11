class ListFilter extends HTMLElement {
  constructor() {
    super()
    this.#attachEvents()
  }

  #attachEvents() {
    this.filterField.addEventListener("keyup", () => {
      const term = this.filterField.value
      this.clearButton.style.visibility = "visible"
      this.filter(term)
    })
    this.clearButton.addEventListener("click", (e) => {
      e.preventDefault()
      this.clear()
    })
    this.filterField.addEventListener("focus", () =>
      key.setScope("list_filter")
    )
    key("esc", "list_filter", () => {
      this.clear()
      this.filterField.blur()
    })
  }

  filter(term) {
    if (term === "") {
      this.clearButton.style.visibility = "hidden"
    }

    this.items.forEach((item) => {
      const name = item.getAttribute(this.nameAttribute)?.toLowerCase()
      // indexOf is much faster then match()
      if (name.indexOf(term.toLowerCase()) !== -1) {
        item.classList.remove("hidden")
      } else {
        item.classList.add("hidden")
      }
    })
  }

  clear() {
    this.filterField.value = ""
    this.filter("")
  }

  get nameAttribute() {
    return this.getAttribute("name-attribute") || "name"
  }

  get clearButton() {
    return this.querySelector('button[type="reset"]')
  }

  get filterField() {
    return this.querySelector('input[type="search"]')
  }

  get items() {
    return document.querySelectorAll(this.itemsSelector)
  }

  get itemsSelector() {
    return this.getAttribute("items-selector")
  }
}

customElements.define("alchemy-list-filter", ListFilter)
