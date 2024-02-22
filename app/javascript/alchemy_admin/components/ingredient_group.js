export class IngredientGroup extends HTMLDetailsElement {
  #localStorageKey = "Alchemy.expanded_ingredient_groups"

  constructor() {
    super()

    this.addEventListener("toggle", this)

    if (this.isInLocalStorage) {
      this.open = true
    }
  }

  /**
   * Toggle visibility of the ingredient fields in this group
   */
  handleEvent() {
    let expanded_ingredient_groups = this.localStorageItem

    if (this.open) {
      this.toggleIcon.name = "arrow-down-s"
      if (!this.isInLocalStorage) expanded_ingredient_groups.push(this.id)
    } else {
      this.toggleIcon.name = "arrow-left-s"
      expanded_ingredient_groups = expanded_ingredient_groups.filter(
        (value) => value !== this.id
      )
    }

    localStorage.setItem(
      this.#localStorageKey,
      JSON.stringify(expanded_ingredient_groups)
    )
  }

  get isInLocalStorage() {
    return this.localStorageItem.includes(this.id)
  }

  get localStorageItem() {
    const item = localStorage.getItem(this.#localStorageKey)

    if (!item) return []

    try {
      return JSON.parse(item)
    } catch (error) {
      console.error(error)
      return []
    }
  }

  get toggleIcon() {
    return this.querySelector("alchemy-icon")
  }
}

customElements.define("alchemy-ingredient-group", IngredientGroup, {
  extends: "details"
})
