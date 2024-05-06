export default class IngredientAnchorLink {
  static updateIcon(ingredientId, active = false) {
    const ingredientEditor = document.querySelector(
      `[data-ingredient-id="${ingredientId}"]`
    )
    if (ingredientEditor) {
      const icon = ingredientEditor.querySelector(
        ".edit-ingredient-anchor-link alchemy-icon"
      )
      icon.setAttribute("icon-style", active ? "fill" : "line")
    }
  }
}
