import "alchemy_admin/components/ingredient_group"
import { renderComponent } from "./component.helper"

describe("alchemy-element-editor", () => {
  const html = `
    <details id="element_123_ingredient_group_kicker" is="alchemy-ingredient-group">
      <summary>Kicker</summary>
    </details>
  `

  afterEach(() => {
    localStorage.clear()
  })

  describe("on click open", () => {
    it("stores ingredient group in localStorage", () => {
      const group = renderComponent("alchemy-ingredient-group", html)
      expect(
        localStorage.hasOwnProperty("Alchemy.expanded_ingredient_groups")
      ).toBeFalsy()
      group.open = true
      // In the browser this event is triggered on change of the open property, but not in JSdom.
      // So we need to dispatch it manually
      const toggle = new Event("toggle")
      group.dispatchEvent(toggle)
      expect(
        localStorage.hasOwnProperty("Alchemy.expanded_ingredient_groups")
      ).toBeTruthy()
    })
  })

  describe("if stored in localStorage", () => {
    beforeEach(() => {
      localStorage.setItem(
        "Alchemy.expanded_ingredient_groups",
        JSON.stringify(["element_123_ingredient_group_kicker"])
      )
    })

    it("opens", () => {
      const group = renderComponent("alchemy-ingredient-group", html)
      expect(group.open).toBeTruthy()
    })

    describe("on click close", () => {
      it("removes ingredient group from localStorage", () => {
        const group = renderComponent("alchemy-ingredient-group", html)
        group.open = false
        // In the browser this event is triggered on change of the open property, but not in JSdom.
        // So we need to dispatch it manually
        const toggle = new Event("toggle")
        group.dispatchEvent(toggle)
        expect(localStorage.getItem("Alchemy.expanded_ingredient_groups")).toBe(
          "[]"
        )
      })
    })
  })
})
