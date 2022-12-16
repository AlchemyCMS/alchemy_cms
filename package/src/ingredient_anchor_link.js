export default class IngredientAnchorLink {
  static updateIcon(ingredientId, active = false) {
    const ingredientEditor = document.querySelector(
      `[data-ingredient-id="${ingredientId}"]`
    )
    if (ingredientEditor) {
      const icon = ingredientEditor.querySelector(
        ".edit-ingredient-anchor-link > a > .icon"
      )
      if (icon) {
        active
          ? icon.classList.replace("far", "fas")
          : icon.classList.replace("fas", "far")
      }
    }
  }
}
