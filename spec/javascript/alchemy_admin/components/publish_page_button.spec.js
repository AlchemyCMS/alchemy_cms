import { vi } from "vitest"
import "alchemy_admin/components/publish_page_button"
import { renderComponent } from "./component.helper.js"

describe("alchemy-publish-page-button", () => {
  let html = `
    <alchemy-publish-page-button>
      <sl-tooltip content="Page is up to date">
        <sl-button variant="default" disabled>Publish</sl-button>
      </sl-tooltip>
    </alchemy-publish-page-button>
  `
  let component

  beforeEach(() => {
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
    it("sets button to loading state", () => {
      const submit = new Event("submit", { bubbles: true })
      component.dispatchEvent(submit)

      expect(component.button.loading).toBe(true)
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
