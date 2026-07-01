import "alchemy_admin/components/element_select"
import { renderComponent } from "./component.helper"

describe("alchemy-element-select", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined
  /**
   * @type {HTMLElement | undefined}
   */
  let wrapper = undefined

  beforeEach(() => {
    const html = `
      <select is="alchemy-element-select" placeholder="Select element">
        <option value="headline" selected
          data-icon="<svg class='icon'></svg>"
          data-hint="Use this for headlines.">Headline</option>
      </select>
    `

    component = renderComponent("alchemy-element-select", html)
    wrapper = document.querySelector(".ts-wrapper")
  })

  it("enhances the select with Tom Select", () => {
    expect(wrapper).toBeInstanceOf(HTMLElement)
  })

  it("renders the selected item with its icon and name", () => {
    const item = wrapper.querySelector(".ts-control .item")
    expect(item).toBeTruthy()
    expect(item.textContent).toContain("Headline")
    expect(item.querySelector("svg")).toBeTruthy()
  })

  it("renders dropdown options with icon, name and hint", () => {
    const option = component.tomselect.render("option", {
      value: "headline",
      text: "Headline",
      icon: "<svg class='icon'></svg>",
      hint: "Use this for headlines."
    })

    expect(option.classList.contains("element-select-item")).toBe(true)
    const name = option.querySelector(".element-select-name")
    expect(name.textContent).toContain("Headline")
    expect(name.querySelector("svg")).toBeTruthy()
    expect(
      option.querySelector(".element-select-description").textContent
    ).toContain("Use this for headlines.")
  })

  it("omits the description when the option has no hint", () => {
    const option = component.tomselect.render("option", {
      value: "text",
      text: "Text",
      icon: "<svg class='icon'></svg>"
    })

    expect(option.querySelector(".element-select-description")).toBeFalsy()
  })
})
