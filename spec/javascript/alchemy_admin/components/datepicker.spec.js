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

  describe("picker without type", () => {
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
      expect(component.inputType).toEqual("date")
    })

    it("creates a flatpickr-calendar on opening", () => {
      expect(document.querySelector(".flatpickr-calendar")).toBeInstanceOf(
        HTMLElement
      )
    })
  })

  describe("with type attribute", () => {
    it("creates only one flatpickr-calendar on opening", () => {
      component.setAttribute("inputType", "datetime")
      expect(
        document.getElementsByClassName("flatpickr-calendar").length
      ).toEqual(1)
    })
  })

  describe("remove datepicker", () => {
    it("removes the flatpickr-calendar after removing", () => {
      component.remove()
      expect(document.querySelector(".flatpickr-calendar")).toBeNull()
    })
  })

  it("should include timezone for time inputs", () => {
    const html = `
      <alchemy-datepicker input-type="time">
        <input type="text">
      </alchemy-datepicker>
    `
    component = renderComponent("alchemy-datepicker", html)
    expect(component.flatpickrOptions.dateFormat).toEqual("Z")
  })

  it("should include timezone for datetime inputs", () => {
    const html = `
      <alchemy-datepicker input-type="datetime">
        <input type="text">
      </alchemy-datepicker>
    `
    component = renderComponent("alchemy-datepicker", html)
    expect(component.flatpickrOptions.dateFormat).toEqual("Z")
  })

  it("should not include timezone for date inputs", () => {
    const html = `
      <alchemy-datepicker input-type="date">
        <input type="text">
      </alchemy-datepicker>
    `
    component = renderComponent("alchemy-datepicker", html)
    expect(component.flatpickrOptions.dateFormat).toBeUndefined()
  })
})
