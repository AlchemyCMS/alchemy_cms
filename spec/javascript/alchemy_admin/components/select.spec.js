import "alchemy_admin/components/select"
import { renderComponent } from "./component.helper"

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
        <option value="">Please Select</option>
        <option value="1">First</option>
        <option value="2">Second</option>
      </select>
    `

    component = renderComponent("alchemy-select", html)
    select2Component = document.querySelector(".select2-container")
  })

  describe("initialize Select2", () => {
    it("should transform the component into a Select2 - component", () => {
      expect(select2Component).toBeInstanceOf(HTMLElement)
    })

    it("should have the alchemy_selectbox - class", () => {
      expect(select2Component?.className).toContain("alchemy_selectbox")
    })
  })

  describe("setOptions", () => {
    it("adds the new entry and replace the old ones", () => {
      component.setOptions(
        [
          { id: "foo", text: "bar" },
          { id: "bar", text: "last" }
        ],
        "Please Select"
      )

      expect(component.options.length).toEqual(3)
      expect(component.options[0].text).toEqual("Please Select")
      expect(component.options[1].text).toEqual("bar")
      expect(component.options[2].text).toEqual("last")
    })

    it("does not add a prompt, if no prompt value is given", () => {
      component.setOptions([
        { id: "foo", text: "bar" },
        { id: "bar", text: "last" }
      ])

      expect(component.options.length).toEqual(2)
      expect(component.options[0].text).toEqual("bar")
      expect(component.options[1].text).toEqual("last")
    })

    it("resets without any options", () => {
      const html = `<select is="alchemy-select"></select>`

      component = renderComponent("alchemy-select", html)
      component.setOptions([{ id: "foo", text: "bar" }])

      expect(component.options.length).toEqual(1)
      expect(component.options[0].text).toEqual("bar")
    })

    it("marks the previous selected option as selected", () => {
      const html = `
        <select is="alchemy-select">
            <option value="1">First</option>
            <option value="2" selected>Second</option>
            <option value="3">Third</option>
        </select>
      `

      component = renderComponent("alchemy-select", html)
      component.setOptions([
        { id: "foo", text: "bar" },
        { id: "2", text: "Second" }
      ])

      expect(component.options.length).toEqual(2)
      expect(component.options[0].text).toEqual("bar")
      expect(component.options[1].text).toEqual("Second")
      expect(component.options[1].selected).toBeTruthy()
    })
  })

  describe("enable", () => {
    it("removes the disabled attribute", () => {
      const html = `<select is="alchemy-select" disabled="disabled"></select>`

      component = renderComponent("alchemy-select", html)
      component.enable()

      expect(component.hasAttribute("disabled")).toBeFalsy()
    })
  })

  describe("disable", () => {
    it("adds the disabled attribute", () => {
      const html = `<select is="alchemy-select"></select>`

      component = renderComponent("alchemy-select", html)
      component.disable()

      expect(component.hasAttribute("disabled")).toBeTruthy()
    })
  })

  describe("with data-allow-clear set", () => {
    it("adds clear button", () => {
      const html = `<select is="alchemy-select" data-allow-clear>
        <option value="">Please Select</option>
        <option value="1">First</option>
        <option value="2">Second</option>
      </select>`

      component = renderComponent("alchemy-select", html)
      select2Component = document.querySelector(".select2-container")
      expect(
        select2Component.querySelector(".select2-search-choice-close")
      ).toBeTruthy()
    })
  })

  describe("without data-allow-clear set", () => {
    it("removes clear button", () => {
      expect(
        select2Component.querySelector(".select2-search-choice-close")
      ).toBeFalsy()
    })
  })
})
