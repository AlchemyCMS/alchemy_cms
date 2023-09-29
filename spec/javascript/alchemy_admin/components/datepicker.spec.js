import "alchemy_admin/components/datepicker"
import { renderComponent, setupLanguage } from "./component.helper"

describe("alchemy-datepicker", () => {
  /**
   *
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  beforeAll(() => setupLanguage())

  beforeEach(() => {
    const html = `
      <alchemy-datepicker>
        <input type="text">
      </alchemy-datepicker>
    `
    component = renderComponent("alchemy-datepicker", html)
  })

  it("should render the input field", () => {
    expect(component.getElementsByTagName("input")[0]).toBeInstanceOf(
      HTMLElement
    )
  })

  it("should enhance the input field with a flat picker config", () => {
    expect(component.getElementsByTagName("input")[0].className).toEqual(
      "flatpickr-input"
    )
  })

  it("should have a type attribute", () => {
    expect(component.type).toEqual("date")
  })
})
