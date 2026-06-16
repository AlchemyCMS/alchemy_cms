import "alchemy_admin/components/element_editor/publish_element_button"
import { renderComponent } from "../component.helper"
import { beforeEach } from "vitest"

describe("alchemy-publish-element-button", () => {
  let html, button

  describe("on click of publish button", () => {
    beforeEach(() => {
      html = `
        <alchemy-publish-element-button>
          <sl-button type="submit" variant="default" outline>Hide</sl-button>
          <sl-dropdown>
            <sl-button slot="trigger" variant="default" outline>Schedule</sl-button>
          </sl-dropdown>
        </alchemy-publish-element-button>
      `
      button = renderComponent("alchemy-publish-element-button", html)
    })

    it("sets button to loading", async () => {
      const click = new Event("click", { bubbles: true })
      const publishButton = button.querySelector("sl-button[type='submit']")

      publishButton.dispatchEvent(click)
      await Promise.resolve()
      expect(publishButton.loading).toBeTruthy()
    })
  })

  describe("on sl-show event", () => {
    describe("when dropdown button is default", () => {
      beforeEach(() => {
        html = `
          <alchemy-publish-element-button>
            <sl-button type="submit" variant="default" outline>Hide</sl-button>
            <sl-dropdown>
              <sl-button slot="trigger" variant="default" outline>Schedule</sl-button>
            </sl-dropdown>
          </alchemy-publish-element-button>
        `
        button = renderComponent("alchemy-publish-element-button", html)
      })

      it("sets button to primary on dropdown show", async () => {
        const show = new CustomEvent("sl-show", { bubbles: true })
        const dropdown = button.querySelector("sl-dropdown")
        const scheduleButton = button.querySelector("sl-button[slot='trigger']")

        dropdown.dispatchEvent(show)
        await Promise.resolve()
        expect(scheduleButton.getAttribute("variant")).toEqual("primary")
      })

      it("sets button to default on dropdown hide", async () => {
        const show = new CustomEvent("sl-hide", { bubbles: true })
        const dropdown = button.querySelector("sl-dropdown")
        const scheduleButton = button.querySelector("sl-button[slot='trigger']")

        dropdown.dispatchEvent(show)
        await Promise.resolve()
        expect(scheduleButton.getAttribute("variant")).toEqual("default")
      })
    })

    describe("when dropdown button is primary", () => {
      beforeEach(() => {
        html = `
          <alchemy-publish-element-button>
            <sl-button type="submit" variant="default" outline>Hide</sl-button>
            <sl-dropdown>
              <sl-button slot="trigger" variant="primary" outline>Schedule</sl-button>
            </sl-dropdown>
          </alchemy-publish-element-button>
        `
        button = renderComponent("alchemy-publish-element-button", html)
      })

      it("keeps button at primary on dropdown hide", async () => {
        const show = new CustomEvent("sl-show", { bubbles: true })
        const dropdown = button.querySelector("sl-dropdown")
        const scheduleButton = button.querySelector("sl-button[slot='trigger']")

        dropdown.dispatchEvent(show)
        await Promise.resolve()
        expect(scheduleButton.getAttribute("variant")).toEqual("primary")
      })
    })
  })
})
