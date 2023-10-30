import "alchemy_admin/components/select"
import { renderComponent } from "./component.helper"

// import jquery and append it to the window object
import jQuery from "jquery"
globalThis.$ = jQuery
globalThis.jQuery = jQuery
import("vendor/jquery_plugins/select2")

describe("alchemy-select", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined
  /**
   * @type {HTMLElement | undefined}
   */
  let select2Component = undefined

  beforeEach(() => {
    const html = `
      <select is="alchemy-select">
        <option value="1">First</option>
        <option value="2">Second</option>
      </select>
    `
    component = renderComponent("alchemy-select", html)
    select2Component = document.querySelector(".select2-container")
  })

  it("should transform the component into a Select2 - component", () => {
    expect(select2Component).toBeInstanceOf(HTMLElement)
  })

  it("should have the alchemy_selectbox - class", () => {
    expect(select2Component?.className).toContain("alchemy_selectbox")
  })
})
