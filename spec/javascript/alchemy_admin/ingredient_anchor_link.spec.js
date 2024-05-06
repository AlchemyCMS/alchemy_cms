import IngredientAnchorLink from "alchemy_admin/ingredient_anchor_link"

describe("IngredientAnchorLink", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div data-ingredient-id="1">
        <a class="edit-ingredient-anchor-link">
          <alchemy-icon icon-style="line"></alchemy-icon>
        </a>
      </div>
    `
  })

  describe(".updateIcon", () => {
    it("sets icon-style to fill if active", () => {
      IngredientAnchorLink.updateIcon(1, true)
      const icon = document.querySelector(
        ".edit-ingredient-anchor-link alchemy-icon"
      )
      expect(icon.getAttribute("icon-style")).toEqual("fill")
    })

    it("sets icon-style to line if not active", () => {
      IngredientAnchorLink.updateIcon(1, false)
      const icon = document.querySelector(
        ".edit-ingredient-anchor-link alchemy-icon"
      )
      expect(icon.getAttribute("icon-style")).toEqual("line")
    })

    it("does nothing if ingredient editor is not found", () => {
      IngredientAnchorLink.updateIcon(2, true)
      const icon = document.querySelector(
        ".edit-ingredient-anchor-link alchemy-icon"
      )
      expect(icon.getAttribute("icon-style")).toEqual("line")
    })
  })
})
