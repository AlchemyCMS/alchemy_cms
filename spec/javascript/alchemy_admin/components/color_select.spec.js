import "alchemy_admin/components/color_select"
import { renderComponent } from "./component.helper"

describe("alchemy-color-select", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined
  /**
   * @type {HTMLElement | undefined}
   */
  let select2Component = undefined
  /**
   * @type {HTMLElement | undefined}
   */
  let colorPicker = undefined

  beforeEach(() => {
    const html = `
      <alchemy-color-select>
        <select>
            <option value="red" selected>Red</option>
            <option value="blue">Blue</option>
            <option value="custom_color">Custom color</option>
        </select>
        <input type="color" disabled="disabled">
      </alchemy-color-select>
    `
    component = renderComponent("alchemy-color-select", html)
    select2Component = document.querySelector(".select2-container")
    colorPicker = document.querySelector("input[type='color']")
  })

  describe("with select", () => {
    it("should initialize Select2", () => {
      expect(select2Component).toBeInstanceOf(HTMLElement)
    })

    it("should have a disabled color picker", () => {
      expect(colorPicker.getAttribute("disabled")).toBe("disabled")
    })

    it("should enable and disabling the color picker", () => {
      $(document.querySelector("select")).trigger(
        jQuery.Event("change", { val: "custom_color" })
      )
      expect(colorPicker.getAttribute("disabled")).toBeNull()

      $(document.querySelector("select")).trigger(
        jQuery.Event("change", { val: "red" })
      )
      expect(colorPicker.getAttribute("disabled")).toBe("")
    })
  })

  describe("without select", () => {
    beforeEach(() => {
      const html = `
      <alchemy-color-select>
        <input type="color" disabled="disabled">
      </alchemy-color-select>
    `
      component = renderComponent("alchemy-color-select", html)
      colorPicker = document.querySelector("input[type='color']")
    })

    it("should enable a disabled color picker", () => {
      expect(colorPicker.getAttribute("disabled")).toBeNull()
    })
  })
})
