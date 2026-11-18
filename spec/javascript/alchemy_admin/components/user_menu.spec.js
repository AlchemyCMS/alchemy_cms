import "alchemy_admin/components/user_menu"
import { renderComponent } from "./component.helper"

describe("alchemy-user-menu", () => {
  let dropdown, containingElementOnMousedown

  const mousedownOn = (element) => {
    element.dispatchEvent(new MouseEvent("mousedown", { bubbles: true }))
  }

  beforeEach(() => {
    renderComponent(
      "alchemy-user-menu",
      `
        <alchemy-user-menu><sl-dropdown></sl-dropdown></alchemy-user-menu>
        <div class="ts-dropdown"><div class="option">Berlin</div></div>
        <h2>Page</h2>
      `
    )
    dropdown = document.querySelector("sl-dropdown")
    dropdown.containingElement = dropdown
    dropdown.open = true
    // Shoelace checks the containing element in a document mousedown listener.
    containingElementOnMousedown = undefined
    document.addEventListener(
      "mousedown",
      () => (containingElementOnMousedown = dropdown.containingElement),
      { once: true }
    )
  })

  it("keeps the dropdown open on a click into a select's options", () => {
    mousedownOn(document.querySelector(".ts-dropdown .option"))
    expect(containingElementOnMousedown).toBe(document.body)
  })

  it("restores the dropdown's outside click detection afterwards", async () => {
    mousedownOn(document.querySelector(".ts-dropdown .option"))
    await new Promise((resolve) => setTimeout(resolve))
    expect(dropdown.containingElement).toBe(dropdown)
  })

  it("leaves clicks elsewhere to the dropdown", () => {
    mousedownOn(document.querySelector("h2"))
    expect(containingElementOnMousedown).toBe(dropdown)
  })
})
