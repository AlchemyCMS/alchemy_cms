import "alchemy_admin/components/color_select"
import { renderComponent } from "./component.helper"

describe("alchemy-color-select", () => {
  /**
   * @type {HTMLSelectElement | undefined}
   */
  let select = undefined
  /**
   * @type {HTMLInputElement | undefined}
   */
  let colorPicker = undefined

  beforeEach(() => {
    const html = `
      <div class="color-select">
        <select is="alchemy-color-select">
          <option value="red" data-swatch="red" selected>Red</option>
          <option value="blue" data-swatch="blue">Blue</option>
          <option value="custom_color">Custom color</option>
        </select>
        <input type="color" disabled="disabled">
      </div>
    `
    select = renderComponent("alchemy-color-select", html)
    colorPicker = document.querySelector("input[type='color']")
  })

  it("enhances the select with Tom Select", () => {
    expect(document.querySelector(".ts-wrapper")).toBeInstanceOf(HTMLElement)
  })

  it("keeps the color picker disabled for a preset color", () => {
    expect(colorPicker.disabled).toBe(true)
  })

  it("enables the color picker for a custom color and disables it otherwise", () => {
    select.tomselect.setValue("custom_color")
    expect(colorPicker.disabled).toBe(false)

    select.tomselect.setValue("red")
    expect(colorPicker.disabled).toBe(true)
  })

  it("renders an option with a color swatch", () => {
    const option = select.tomselect.render("option", {
      value: "red",
      text: "Red",
      swatch: "red"
    })

    expect(option.classList.contains("select-color-option")).toBe(true)
    const indicator = option.querySelector(".color-indicator")
    expect(indicator.getAttribute("style")).toContain("--color: red")
    expect(option.textContent).toContain("Red")
  })

  it("renders the custom color option with a palette icon", () => {
    const option = select.tomselect.render("option", {
      value: "custom_color",
      text: "Custom color"
    })

    expect(option.querySelector("alchemy-icon[name='palette']")).toBeTruthy()
    expect(option.querySelector(".color-indicator")).toBeFalsy()
  })
})

describe("alchemy-color-input", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined
  /**
   * @type {HTMLInputElement | undefined}
   */
  let colorPicker = undefined
  /**
   * @type {HTMLInputElement | undefined}
   */
  let textInput = undefined

  beforeEach(() => {
    const html = `
      <alchemy-color-input class="color-select">
        <input type="text">
        <input type="color" disabled="disabled">
      </alchemy-color-input>
    `
    component = renderComponent("alchemy-color-input", html)
    colorPicker = component.querySelector("input[type='color']")
    textInput = component.querySelector("input[type='text']")
  })

  it("enables the color picker", () => {
    expect(colorPicker.disabled).toBe(false)
  })

  it("syncs value from the color picker to the text input", () => {
    colorPicker.value = "#ff0000"
    colorPicker.dispatchEvent(new Event("input", { bubbles: true }))
    expect(textInput.value).toBe("#ff0000")
  })

  it("syncs value from the text input to the color picker", () => {
    textInput.value = "#ff0000"
    textInput.dispatchEvent(new Event("input", { bubbles: true }))
    expect(colorPicker.value).toBe("#ff0000")
  })
})
