import { vi } from "vitest"

vi.mock("alchemy_admin/confirm_dialog", () => ({
  __esModule: true,
  openConfirmDialog: vi.fn()
}))

vi.mock("alchemy_admin/please_wait_overlay", () => ({
  __esModule: true,
  default: vi.fn()
}))

import "alchemy_admin/components/dirty_guard"
import { openConfirmDialog } from "alchemy_admin/confirm_dialog"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"
import { renderComponent } from "./component.helper.js"

describe("alchemy-dirty-guard", () => {
  let html = `
    <alchemy-element-editor id="element_editor"></alchemy-element-editor>
    <div id="outer">
      <alchemy-dirty-guard>
        <form id="guarded_form" action="/admin/pages/1/unlock" method="post">
          <input type="hidden" name="authenticity_token" value="s3cr3t">
          <button type="submit">Unlock</button>
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
  let requestSubmit
  let submittedForms

  const flush = () => new Promise((resolve) => setTimeout(resolve))

  const makeDirty = () =>
    document.querySelector("#element_editor").classList.add("dirty")

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
    globalThis.Turbo = { visit: vi.fn() }
    submittedForms = []
    requestSubmit = vi
      .spyOn(HTMLFormElement.prototype, "requestSubmit")
      .mockImplementation(function () {
        submittedForms.push(this)
      })
    component = renderComponent("alchemy-dirty-guard", html)
    outerSubmit = vi.fn()
    outerClick = vi.fn()
    const outer = document.querySelector("#outer")
    outer.addEventListener("submit", outerSubmit)
    outer.addEventListener("click", outerClick)
  })

  afterEach(() => {
    requestSubmit.mockRestore()
    delete globalThis.Turbo
    window.onbeforeunload = null
  })

  describe("without unsaved changes", () => {
    it("lets a form submit through", () => {
      const event = submitForm()

      expect(event.defaultPrevented).toBe(false)
      expect(outerSubmit).toHaveBeenCalled()
      expect(openConfirmDialog).not.toHaveBeenCalled()
    })

    it("lets a link click through", () => {
      const event = clickOn("#guarded_link")

      expect(event.defaultPrevented).toBe(false)
      expect(outerClick).toHaveBeenCalled()
      expect(openConfirmDialog).not.toHaveBeenCalled()
    })
  })

  describe("with unsaved changes", () => {
    beforeEach(makeDirty)

    describe("submitting a wrapped form", () => {
      it("prevents the submit and asks for confirmation", () => {
        openConfirmDialog.mockResolvedValue(false)
        const event = submitForm()

        expect(event.defaultPrevented).toBe(true)
        expect(openConfirmDialog).toHaveBeenCalledWith(
          "page_dirty_notice",
          expect.any(Object)
        )
      })

      it("stops the event before components around the guard react", () => {
        openConfirmDialog.mockResolvedValue(false)
        submitForm()

        expect(outerSubmit).not.toHaveBeenCalled()
      })

      it("submits the form's inputs to its action once confirmed", async () => {
        openConfirmDialog.mockResolvedValue(true)
        submitForm()
        await flush()

        expect(submittedForms).toHaveLength(1)
        const [submitted] = submittedForms
        expect(new URL(submitted.action).pathname).toBe("/admin/pages/1/unlock")
        expect(submitted.method).toBe("post")
        expect(
          submitted.querySelector("input[name='authenticity_token']").value
        ).toBe("s3cr3t")
        expect(pleaseWaitOverlay).toHaveBeenCalled()
      })

      it("does nothing when the confirmation is cancelled", async () => {
        openConfirmDialog.mockResolvedValue(false)
        submitForm()
        await flush()

        expect(submittedForms).toHaveLength(0)
        expect(pleaseWaitOverlay).not.toHaveBeenCalled()
      })
    })

    describe("clicking a wrapped link", () => {
      it("prevents the click and asks for confirmation", () => {
        openConfirmDialog.mockResolvedValue(false)
        const event = clickOn("#guarded_link")

        expect(event.defaultPrevented).toBe(true)
        expect(openConfirmDialog).toHaveBeenCalled()
      })

      it("guards the link when one of its children was clicked", () => {
        openConfirmDialog.mockResolvedValue(false)
        const event = clickOn("#link_label")

        expect(event.defaultPrevented).toBe(true)
        expect(openConfirmDialog).toHaveBeenCalled()
      })

      it("stops the event before components around the guard react", () => {
        openConfirmDialog.mockResolvedValue(false)
        clickOn("#guarded_link")

        expect(outerClick).not.toHaveBeenCalled()
      })

      it("visits the link once confirmed", async () => {
        openConfirmDialog.mockResolvedValue(true)
        clickOn("#guarded_link")
        await flush()

        expect(Turbo.visit).toHaveBeenCalledWith("/admin/languages")
      })

      it("does not visit the link when the confirmation is cancelled", async () => {
        openConfirmDialog.mockResolvedValue(false)
        clickOn("#guarded_link")
        await flush()

        expect(Turbo.visit).not.toHaveBeenCalled()
      })
    })

    it("clears the unload warning once confirmed", async () => {
      window.onbeforeunload = () => {}
      openConfirmDialog.mockResolvedValue(true)
      clickOn("#guarded_link")
      await flush()

      expect(window.onbeforeunload).toBeFalsy()
    })

    it("ignores clicks on anything that is not a link", () => {
      const event = clickOn("#bare_button")

      expect(event.defaultPrevented).toBe(false)
      expect(openConfirmDialog).not.toHaveBeenCalled()
    })
  })

  describe("disconnectedCallback", () => {
    it("stops guarding", () => {
      makeDirty()
      const form = document.querySelector("#guarded_form")
      const outer = document.querySelector("#outer")
      component.remove()
      outer.append(form)

      const event = new Event("submit", { bubbles: true, cancelable: true })
      form.dispatchEvent(event)

      expect(event.defaultPrevented).toBe(false)
      expect(openConfirmDialog).not.toHaveBeenCalled()
    })
  })
})
