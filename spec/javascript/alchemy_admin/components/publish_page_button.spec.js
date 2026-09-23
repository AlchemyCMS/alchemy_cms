import { vi } from "vitest"

vi.mock("alchemy_admin/dirty", () => ({
  __esModule: true,
  checkPageDirtyness: vi.fn()
}))

import "alchemy_admin/components/publish_page_button"
import { checkPageDirtyness } from "alchemy_admin/dirty"
import { renderComponent } from "./component.helper.js"

describe("alchemy-publish-page-button", () => {
  let html = `
    <alchemy-publish-page-button>
      <sl-tooltip content="Page is up to date">
        <form id="publish_page_form" action="/admin/pages/1/publish">
          <sl-button variant="default" disabled>Publish</sl-button>
        </form>
      </sl-tooltip>
    </alchemy-publish-page-button>
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
    component = renderComponent("alchemy-publish-page-button", html)
  })

  describe("button getter", () => {
    it("returns the sl-button element", () => {
      expect(component.button).toBe(component.querySelector("sl-button"))
    })
  })

  describe("tooltip getter", () => {
    it("returns the sl-tooltip element", () => {
      expect(component.tooltip).toBe(component.querySelector("sl-tooltip"))
    })
  })

  describe("on submit", () => {
    it("checks the page for unsaved changes", () => {
      submitForm()

      expect(checkPageDirtyness).toHaveBeenCalledWith(
        component.querySelector("form")
      )
    })

    it("sets button to loading state", () => {
      const event = submitForm()

      expect(component.button.loading).toBe(true)
      expect(event.defaultPrevented).toBe(false)
    })

    describe("with unsaved changes", () => {
      beforeEach(() => checkPageDirtyness.mockReturnValue(false))

      it("prevents the submit", () => {
        const event = submitForm()

        expect(event.defaultPrevented).toBe(true)
      })

      it("does not leave the button in loading state", () => {
        submitForm()

        expect(component.button.loading).toBeUndefined()
      })
    })
  })

  describe("on alchemy:page-dirty event", () => {
    it("marks the button as dirty", () => {
      const detail = { tooltip: "Page has unpublished changes" }
      const pageDirty = new CustomEvent("alchemy:page-dirty", {
        bubbles: true,
        detail
      })
      document.dispatchEvent(pageDirty)

      expect(component.button.variant).toBe("primary")
      expect(component.button.disabled).toBe(false)
      expect(component.tooltip.content).toBe("Page has unpublished changes")
    })
  })

  describe("disconnectedCallback", () => {
    it("stops listening for alchemy:page-dirty events", () => {
      const markDirtySpy = vi.spyOn(component, "markDirty")
      component.remove()

      const detail = { tooltip: "Page has unpublished changes" }
      const pageDirty = new CustomEvent("alchemy:page-dirty", {
        bubbles: true,
        detail
      })
      document.dispatchEvent(pageDirty)

      expect(markDirtySpy).not.toHaveBeenCalled()
    })
  })
})
