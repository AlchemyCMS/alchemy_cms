const DEFAULT_DEBOUNCE_TIME = 150

class ListFilter extends HTMLElement {
  #debounceTimer
  #filterField = null
  #clearButton = null

  connectedCallback() {
    if (this.hotkey) {
      key(this.hotkey, this.#onHotkey)
    }
    this.#filterField = this.filterField
    this.#filterField.addEventListener("keyup", this.#onKeyup)
    this.#filterField.addEventListener("focus", this.#onFocus)

    this.#clearButton = this.clearButton
    this.#clearButton.addEventListener("click", this.#onClearClick)

    key("esc", "list_filter", this.#onEscape)
  }

  disconnectedCallback() {
    clearTimeout(this.#debounceTimer)
    this.#filterField?.removeEventListener("keyup", this.#onKeyup)
    this.#filterField?.removeEventListener("focus", this.#onFocus)
    this.#filterField = null
    this.#clearButton?.removeEventListener("click", this.#onClearClick)
    this.#clearButton = null
    if (this.hotkey) {
      key.unbind(this.hotkey)
    }
    key.unbind("esc", "list_filter")
  }

  filter(term) {
    if (term === "") {
      this.clearButton.style.visibility = "hidden"
    }

    const matchedItems = []
    const itemsToShow = new Set()
    const lowerTerm = term.toLowerCase()

    // First pass: find matching items and mark their ancestors as visible too
    this.items.forEach((item) => {
      const name = item.getAttribute(this.nameAttribute)?.toLowerCase()
      // indexOf is much faster then match()
      if (name.indexOf(lowerTerm) !== -1) {
        matchedItems.push(item)
        itemsToShow.add(item)
        // Mark ancestor items as visible so nested matches stay visible
        let ancestor = item.parentElement?.closest(this.itemsSelector)
        while (ancestor) {
          itemsToShow.add(ancestor)
          ancestor = ancestor.parentElement?.closest(this.itemsSelector)
        }
      }
    })

    // Second pass: apply visibility
    this.items.forEach((item) => {
      item.classList.toggle("hidden", !itemsToShow.has(item))
    })

    // Scroll into view if only one match
    if (matchedItems.length === 1) {
      matchedItems[0].scrollIntoView({ behavior: "smooth", block: "nearest" })
    }
  }

  clear() {
    this.filterField.value = ""
    this.clearButton.style.visibility = "hidden"
    this.items.forEach((item) => item.classList.remove("hidden"))
  }

  get nameAttribute() {
    return this.getAttribute("name-attribute") || "name"
  }

  get clearButton() {
    return this.querySelector('button[type="button"]')
  }

  get filterField() {
    return this.querySelector('input[type="text"]')
  }

  get items() {
    return document.querySelectorAll(this.itemsSelector)
  }

  get itemsSelector() {
    return this.getAttribute("items-selector")
  }

  get debounceTime() {
    return parseInt(this.getAttribute("debounce-time")) || DEFAULT_DEBOUNCE_TIME
  }

  get hotkey() {
    return this.getAttribute("hotkey")
  }

  #onHotkey = () => {
    this.filterField.focus()
    return false
  }

  #onKeyup = () => {
    clearTimeout(this.#debounceTimer)
    this.#debounceTimer = setTimeout(() => {
      const term = this.filterField.value
      this.clearButton.style.visibility = term ? "visible" : "hidden"
      this.filter(term)
    }, this.debounceTime)
  }

  #onFocus = () => key.setScope("list_filter")

  #onClearClick = (e) => {
    e.preventDefault()
    this.clear()
  }

  #onEscape = () => {
    this.clear()
    this.filterField.blur()
  }
}

customElements.define("alchemy-list-filter", ListFilter)
