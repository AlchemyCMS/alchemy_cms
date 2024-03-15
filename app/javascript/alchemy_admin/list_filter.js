// The Alchemy list filter
//
// The list items must have a name attribute.
//
// It hides all list items that don't match the term from filter input field.
//
class ListFilterHandler {
  // Pass a input field with a data-alchemy-list-filter attribute to this constructor
  constructor(filter_field) {
    this.filterField = filter_field
    this.items = document.querySelectorAll(
      filter_field.dataset.alchemyListFilter
    )
    this.clearButton = filter_field.parentNode.querySelector(
      ".js_filter_field_clear"
    )
    this.observe()
  }

  observe() {
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
      const name = item.getAttribute("name").toLowerCase()
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
}

// Initializes an ListFilterHandler on all input fields with a data-alchemy-list-filter attribute.
//
export default function ListFilter(scope = document) {
  if (scope instanceof jQuery) {
    scope = scope[0]
  }
  scope.querySelectorAll("[data-alchemy-list-filter]").forEach((field) => {
    new ListFilterHandler(field)
  })
}
