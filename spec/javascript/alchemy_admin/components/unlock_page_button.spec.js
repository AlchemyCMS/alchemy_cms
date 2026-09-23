import { vi } from "vitest"

vi.mock("alchemy_admin/dirty", () => ({
  __esModule: true,
  checkPageDirtyness: vi.fn()
}))

import "alchemy_admin/components/unlock_page_button"
import { checkPageDirtyness } from "alchemy_admin/dirty"
import { renderComponent } from "./component.helper.js"

describe("alchemy-unlock-page-button", () => {
  let html = `
    <alchemy-unlock-page-button>
      <sl-tooltip content="Unlock page">
        <form id="unlock_page_form" action="/admin/pages/1/unlock">
          <button class="icon_button">Unlock</button>
        </form>
      </sl-tooltip>
    </alchemy-unlock-page-button>
  `
  let component

  const submitForm = () => {
    const event = new Event("submit", { bubbles: true, cancelable: true })
    component.querySelector("form").dispatchEvent(event)
    return event
  }

  beforeEach(() => {
    vi.clearAllMocks()
    checkPageDirtyness.mockReturnValue(true)
    component = renderComponent("alchemy-unlock-page-button", html)
  })

  describe("on submit", () => {
    it("checks the page for unsaved changes", () => {
      submitForm()

      expect(checkPageDirtyness).toHaveBeenCalledWith(
        component.querySelector("form")
      )
    })

    it("submits the form", () => {
      const event = submitForm()

      expect(event.defaultPrevented).toBe(false)
    })

    describe("with unsaved changes", () => {
      beforeEach(() => checkPageDirtyness.mockReturnValue(false))

      it("prevents the submit", () => {
        const event = submitForm()

        expect(event.defaultPrevented).toBe(true)
      })
    })
  })

  describe("disconnectedCallback", () => {
    it("stops guarding the submit", () => {
      checkPageDirtyness.mockReturnValue(false)
      const form = component.querySelector("form")
      component.remove()

      const event = new Event("submit", { bubbles: true, cancelable: true })
      form.dispatchEvent(event)

      expect(event.defaultPrevented).toBe(false)
    })
  })
})
