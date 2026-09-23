import { vi } from "vitest"

vi.mock("alchemy_admin/dirty", () => ({
  __esModule: true,
  checkPageDirtyness: vi.fn()
}))

import "alchemy_admin/components/dirty_guard"
import { checkPageDirtyness } from "alchemy_admin/dirty"
import { renderComponent } from "./component.helper.js"

describe("alchemy-dirty-guard", () => {
  let html = `
    <div id="outer">
      <alchemy-dirty-guard>
        <form id="guarded_form" action="/admin/pages/1/publish">
          <button type="submit">Publish</button>
        </form>
        <a id="guarded_link" href="/admin/languages">
          <span id="link_label">Languages</span>
        </a>
        <button id="bare_button">Nothing</button>
      </alchemy-dirty-guard>
    </div>
  `
  let component
  let outerSubmit
  let outerClick

  const submitForm = () => {
    const event = new Event("submit", { bubbles: true, cancelable: true })
    document.querySelector("#guarded_form").dispatchEvent(event)
    return event
  }

  const clickOn = (selector) => {
    const event = new MouseEvent("click", { bubbles: true, cancelable: true })
    document.querySelector(selector).dispatchEvent(event)
    return event
  }

  beforeEach(() => {
    vi.clearAllMocks()
    checkPageDirtyness.mockReturnValue(true)
    component = renderComponent("alchemy-dirty-guard", html)
    outerSubmit = vi.fn()
    outerClick = vi.fn()
    const outer = document.querySelector("#outer")
    outer.addEventListener("submit", outerSubmit)
    outer.addEventListener("click", outerClick)
  })

  describe("submitting a wrapped form", () => {
    it("checks the form for unsaved changes", () => {
      submitForm()

      expect(checkPageDirtyness).toHaveBeenCalledWith(
        document.querySelector("#guarded_form")
      )
    })

    it("lets the submit through when the page is clean", () => {
      const event = submitForm()

      expect(event.defaultPrevented).toBe(false)
      expect(outerSubmit).toHaveBeenCalled()
    })

    describe("when the page is dirty", () => {
      beforeEach(() => checkPageDirtyness.mockReturnValue(false))

      it("prevents the submit", () => {
        const event = submitForm()

        expect(event.defaultPrevented).toBe(true)
      })

      it("stops the event before components around the guard react", () => {
        submitForm()

        expect(outerSubmit).not.toHaveBeenCalled()
      })
    })
  })

  describe("clicking a wrapped link", () => {
    it("checks the link for unsaved changes", () => {
      clickOn("#guarded_link")

      expect(checkPageDirtyness).toHaveBeenCalledWith(
        document.querySelector("#guarded_link")
      )
    })

    it("checks the link when one of its children was clicked", () => {
      clickOn("#link_label")

      expect(checkPageDirtyness).toHaveBeenCalledWith(
        document.querySelector("#guarded_link")
      )
    })

    it("lets the click through when the page is clean", () => {
      const event = clickOn("#guarded_link")

      expect(event.defaultPrevented).toBe(false)
      expect(outerClick).toHaveBeenCalled()
    })

    describe("when the page is dirty", () => {
      beforeEach(() => checkPageDirtyness.mockReturnValue(false))

      it("prevents the click", () => {
        const event = clickOn("#guarded_link")

        expect(event.defaultPrevented).toBe(true)
      })

      it("stops the event before components around the guard react", () => {
        clickOn("#guarded_link")

        expect(outerClick).not.toHaveBeenCalled()
      })
    })
  })

  describe("clicking something that is neither a link nor a submit", () => {
    beforeEach(() => checkPageDirtyness.mockReturnValue(false))

    it("does not check for unsaved changes", () => {
      const event = clickOn("#bare_button")

      expect(checkPageDirtyness).not.toHaveBeenCalled()
      expect(event.defaultPrevented).toBe(false)
    })
  })

  describe("disconnectedCallback", () => {
    it("stops guarding", () => {
      checkPageDirtyness.mockReturnValue(false)
      const form = document.querySelector("#guarded_form")
      const outer = document.querySelector("#outer")
      component.remove()
      outer.append(form)

      const event = new Event("submit", { bubbles: true, cancelable: true })
      form.dispatchEvent(event)

      expect(checkPageDirtyness).not.toHaveBeenCalled()
      expect(event.defaultPrevented).toBe(false)
    })
  })
})
