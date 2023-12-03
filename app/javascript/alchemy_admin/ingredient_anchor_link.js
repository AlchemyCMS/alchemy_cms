export default class IngredientAnchorLink {
  static updateIcon(ingredientId, active = false) {
    const ingredientEditor = document.querySelector(
      `[data-ingredient-id="${ingredientId}"]`
    )
    if (ingredientEditor) {
      const icon = ingredientEditor.querySelector(
        ".edit-ingredient-anchor-link > a > .icon"
      )
      icon?.classList.toggle("ri-bookmark-fill", active)
      icon?.classList.toggle("ri-bookmark-line", !active)
    }
  }
}
