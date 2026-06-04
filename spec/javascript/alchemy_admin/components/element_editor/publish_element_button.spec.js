import "alchemy_admin/components/element_editor/publish_element_button"
import { renderComponent } from "../component.helper"
import { beforeEach } from "vitest"

describe("alchemy-publish-element-button", () => {
  let html, button

  describe("on click of publish button", () => {
    beforeEach(() => {
      html = `
        <alchemy-element-editor>
          <alchemy-publish-element-button>
            <sl-button type="submit" variant="default" outline>Hide</sl-button>
            <sl-button class="schedule-trigger" variant="default" outline>Schedule</sl-button>
          </alchemy-publish-element-button>
        </alchemy-element-editor>
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

  describe("on click of schedule button", () => {
    describe("when dropdown button is default", () => {
      beforeEach(() => {
        html = `
          <alchemy-element-editor>
            <alchemy-publish-element-button>
              <sl-button type="submit" variant="default" outline>Hide</sl-button>
              <sl-dropdown>
                <sl-button class="schedule-trigger" variant="default" outline>Schedule</sl-button>
              </sl-dropdown>
            </alchemy-publish-element-button>
            <div class="element-schedule-form" hidden></div>
          </alchemy-element-editor>
        `
        button = renderComponent("alchemy-publish-element-button", html)
      })

      it("sets button to primary on show", () => {
        const scheduleButton = button.querySelector(
          "sl-button[class='schedule-trigger']"
        )

        scheduleButton.click()
        expect(scheduleButton.getAttribute("variant")).toEqual("primary")
      })

      it("sets button to default on hide", () => {
        const scheduleButton = button.querySelector(
          "sl-button[class='schedule-trigger']"
        )

        button.scheduleForm.hidden = false

        scheduleButton.click()
        expect(scheduleButton.getAttribute("variant")).toEqual("default")
      })
    })

    describe("when dropdown button is primary", () => {
      beforeEach(() => {
        html = `
          <alchemy-element-editor>
            <alchemy-publish-element-button>
              <sl-button type="submit" variant="default" outline>Hide</sl-button>
              <sl-dropdown>
                <sl-button class="schedule-trigger" variant="primary" outline>Schedule</sl-button>
              </sl-dropdown>
            </alchemy-publish-element-button>
            <div class="element-schedule-form" hidden></div>
          </alchemy-element-editor>
        `
        button = renderComponent("alchemy-publish-element-button", html)
      })

      it("keeps button at primary on hide", () => {
        const scheduleButton = button.querySelector(
          "sl-button[class='schedule-trigger']"
        )

        scheduleButton.click()
        expect(scheduleButton.getAttribute("variant")).toEqual("primary")
      })
    })
  })
})
