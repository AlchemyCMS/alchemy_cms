// The Alchemy list filter
//
// The list items must have a name attribute.
//
// It hides all list items that don't match the term from filter input field.
//
class ListFilterHandler {
  // Pass a input field with a data-alchemy-list-filter attribute to this constructor
  constructor(filter) {
    this.filter_field = $(filter)
    this.items = $(this.filter_field.data("alchemy-list-filter"))
    this.clear = this.filter_field.siblings(".js_filter_field_clear")
    this._observe()
  }

  _observe() {
    this.filter_field.on("keyup", (e) => {
      this.clear.css("visibility", "visible")
      this._filter(this.filter_field.val())
    })
    this.clear.on("click", (e) => {
      e.preventDefault()
      this._clear()
    })
    this.filter_field.on("focus", () => key.setScope("list_filter"))
    key("esc", "list_filter", () => {
      this._clear()
      this.filter_field.blur()
    })
  }

  _filter(term) {
    if (term === "") {
      this.clear.css("visibility", "hidden")
    }
    this.items.map(function () {
      const item = $(this)
      // indexOf is much faster then match()
      if (item.attr("name").toLowerCase().indexOf(term.toLowerCase()) !== -1) {
        item.show()
      } else {
        item.hide()
      }
    })
  }

  _clear() {
    this.filter_field.val("")
    this._filter("")
  }
}

// Initializes an Alchemy.ListFilterHandler on all input fields with a data-alchemy-list-filter attribute.
//
export default function ListFilter(scope) {
  $("[data-alchemy-list-filter]", scope).map(function () {
    new ListFilterHandler(this)
  })
}
