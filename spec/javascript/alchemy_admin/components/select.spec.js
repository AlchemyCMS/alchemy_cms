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
  let wrapper = undefined

  beforeEach(() => {
    const html = `
      <select is="alchemy-select">
        <option value="">Please Select</option>
        <option value="1">First</option>
        <option value="2">Second</option>
      </select>
    `

    component = renderComponent("alchemy-select", html)
    wrapper = document.querySelector(".ts-wrapper")
  })

  describe("initialization", () => {
    it("enhances the select with Tom Select", () => {
      expect(wrapper).toBeInstanceOf(HTMLElement)
    })

    it("copies the alchemy_selectbox class onto the wrapper", () => {
      expect(wrapper?.className).toContain("alchemy_selectbox")
    })
  })

  describe("focus", () => {
    it("focuses the Tom Select control instead of the hidden native select", () => {
      component.focus()

      expect(document.activeElement).toEqual(
        wrapper.querySelector(".ts-control input")
      )
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

      const texts = Array.from(component.options).map((option) => option.text)
      expect(component.options.length).toEqual(2)
      expect(texts).toContain("bar")
      expect(texts).toContain("last")
      // no empty prompt option was added
      expect(
        Array.from(component.options).some((option) => option.value === "")
      ).toBe(false)
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
    it("adds a clear button", () => {
      const html = `<select is="alchemy-select" data-allow-clear>
        <option value="">Please Select</option>
        <option value="1">First</option>
        <option value="2">Second</option>
      </select>`

      renderComponent("alchemy-select", html)
      wrapper = document.querySelector(".ts-wrapper")

      expect(wrapper.querySelector(".clear-button")).toBeTruthy()
    })
  })

  describe("without data-allow-clear set", () => {
    it("does not add a clear button", () => {
      expect(wrapper.querySelector(".clear-button")).toBeFalsy()
    })
  })

  describe("with multiple attribute", () => {
    it("renders a multi-select wrapper", () => {
      const html = `<select is="alchemy-select" multiple>
        <option value="1" selected>First</option>
        <option value="2" selected>Second</option>
        <option value="3">Third</option>
      </select>`

      component = renderComponent("alchemy-select", html)
      wrapper = document.querySelector(".ts-wrapper")

      expect(component.multiple).toBeTruthy()
      expect(wrapper.classList.contains("multi")).toBeTruthy()
    })

    it("allows removing selected items", () => {
      const html = `<select is="alchemy-select" multiple>
        <option value="1" selected>First</option>
        <option value="2" selected>Second</option>
        <option value="3">Third</option>
      </select>`

      renderComponent("alchemy-select", html)
      wrapper = document.querySelector(".ts-wrapper")

      expect(wrapper.querySelector(".item .remove")).toBeTruthy()
    })
  })

  describe("with a placeholder", () => {
    it("starts empty when no option is selected, so the placeholder shows", () => {
      const html = `<select is="alchemy-select" placeholder="Select one">
        <option value="1">First</option>
        <option value="2">Second</option>
      </select>`

      component = renderComponent("alchemy-select", html)

      expect(component.tomselect.items).toEqual([])
    })

    it("keeps an explicitly selected option", () => {
      const html = `<select is="alchemy-select" placeholder="Select one">
        <option value="1">First</option>
        <option value="2" selected>Second</option>
      </select>`

      component = renderComponent("alchemy-select", html)

      expect(component.tomselect.items).toEqual(["2"])
    })
  })

  describe("without a placeholder", () => {
    it("keeps the first option selected when none is selected", () => {
      const html = `<select is="alchemy-select">
        <option value="1">First</option>
        <option value="2">Second</option>
      </select>`

      component = renderComponent("alchemy-select", html)

      expect(component.tomselect.items).toEqual(["1"])
    })
  })

  describe("autofocus", () => {
    it("focuses the control when the select has autofocus", () => {
      const html = `<select is="alchemy-select" autofocus>
        <option value="1">First</option>
        <option value="2">Second</option>
      </select>`

      renderComponent("alchemy-select", html)

      expect(document.activeElement).toEqual(
        document.querySelector(".ts-control input")
      )
    })

    it("does not focus the control without autofocus", () => {
      expect(document.activeElement).not.toEqual(
        wrapper.querySelector(".ts-control input")
      )
    })
  })

  describe("disconnectedCallback", () => {
    it("tears down Tom Select when removed from the DOM", () => {
      expect(document.querySelector(".ts-wrapper")).toBeTruthy()

      component.remove()

      expect(document.querySelector(".ts-wrapper")).toBeFalsy()
    })
  })
})
