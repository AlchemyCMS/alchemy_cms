import "alchemy_admin/components/node_form"
import { renderComponent } from "./component.helper"

describe("alchemy-node-form", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined
  let nameField = undefined
  let urlField = undefined

  const dispatchChange = (added) => {
    component.dispatchEvent(
      new CustomEvent("Alchemy.RemoteSelect.Change", {
        bubbles: true,
        detail: { added }
      })
    )
  }

  beforeEach(() => {
    const html = `
      <alchemy-node-form>
        <form id="node_form">
          <input type="text" id="node_name">
          <input type="text" id="node_url">
        </form>
      </alchemy-node-form>
    `
    component = renderComponent("alchemy-node-form", html)
    nameField = component.querySelector("#node_name")
    urlField = component.querySelector("#node_url")
  })

  describe("when a page is selected", () => {
    beforeEach(() => {
      dispatchChange({ name: "About us", url_path: "/about-us" })
    })

    it("sets the name field placeholder to the page name", () => {
      expect(nameField.getAttribute("placeholder")).toEqual("About us")
    })

    it("fills the url field with the page url path", () => {
      expect(urlField.value).toEqual("/about-us")
    })

    it("disables the url field", () => {
      expect(urlField.hasAttribute("disabled")).toBeTruthy()
    })
  })

  describe("when the page selection is cleared", () => {
    beforeEach(() => {
      nameField.setAttribute("placeholder", "About us")
      urlField.value = "/about-us"
      urlField.setAttribute("disabled", "disabled")
      dispatchChange(undefined)
    })

    it("removes the name field placeholder", () => {
      expect(nameField.hasAttribute("placeholder")).toBeFalsy()
    })

    it("clears the url field", () => {
      expect(urlField.value).toEqual("")
    })

    it("enables the url field", () => {
      expect(urlField.hasAttribute("disabled")).toBeFalsy()
    })
  })
})
