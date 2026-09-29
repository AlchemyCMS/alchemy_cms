import { vi } from "vitest"

vi.mock("alchemy_admin/confirm_dialog", () => ({
  __esModule: true,
  openConfirmDialog: vi.fn()
}))

vi.mock("alchemy_admin/please_wait_overlay", () => ({
  __esModule: true,
  default: vi.fn()
}))

import { Turbo } from "@hotwired/turbo-rails"
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
        <a id="inner_link" href="/admin/languages">Languages</a>
      </alchemy-dirty-guard>
    </div>
  `
  let component
  let form
  let outerSubmit
  let requestSubmit

  const flush = () => new Promise((resolve) => setTimeout(resolve))

  const makeDirty = () =>
    document.querySelector("#element_editor").classList.add("dirty")

  const submitForm = () => {
    const event = new Event("submit", { bubbles: true, cancelable: true })
    form.dispatchEvent(event)
    return event
  }

  const beforeVisit = (url = "http://localhost/admin/languages?page=2#top") => {
    const event = new CustomEvent("turbo:before-visit", {
      bubbles: true,
      cancelable: true,
      detail: { url }
    })
    document.dispatchEvent(event)
    return event
  }

  beforeEach(() => {
    vi.clearAllMocks()
    // A new page has loaded, so nothing has been confirmed yet.
    document.dispatchEvent(new Event("turbo:load"))
    vi.spyOn(Turbo, "visit").mockImplementation(() => {})
    // jsdom cannot submit a form, so only fire the submit event it would send.
    requestSubmit = vi
      .spyOn(HTMLFormElement.prototype, "requestSubmit")
      .mockImplementation(function () {
        this.dispatchEvent(
          new Event("submit", { bubbles: true, cancelable: true })
        )
      })
    component = renderComponent("alchemy-dirty-guard", html)
    form = document.querySelector("#guarded_form")
    outerSubmit = vi.fn()
    document.querySelector("#outer").addEventListener("submit", outerSubmit)
  })

  afterEach(() => {
    requestSubmit.mockRestore()
    Turbo.visit.mockRestore()
    window.onbeforeunload = null
  })

  describe("submitting a wrapped form", () => {
    it("lets the submit through without unsaved changes", () => {
      const event = submitForm()

      expect(event.defaultPrevented).toBe(false)
      expect(outerSubmit).toHaveBeenCalled()
      expect(openConfirmDialog).not.toHaveBeenCalled()
    })

    describe("with unsaved changes", () => {
      beforeEach(makeDirty)

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

      it("submits the form itself again once confirmed", async () => {
        openConfirmDialog.mockResolvedValue(true)
        submitForm()
        await flush()

        expect(requestSubmit).toHaveBeenCalledTimes(1)
        expect(requestSubmit.mock.contexts[0]).toBe(form)
        expect(outerSubmit).toHaveBeenCalledTimes(1)
        expect(openConfirmDialog).toHaveBeenCalledTimes(1)
        expect(pleaseWaitOverlay).toHaveBeenCalled()
      })

      it("does nothing when the confirmation is cancelled", async () => {
        openConfirmDialog.mockResolvedValue(false)
        submitForm()
        await flush()

        expect(requestSubmit).not.toHaveBeenCalled()
        expect(pleaseWaitOverlay).not.toHaveBeenCalled()
      })

      it("does not ask again when the confirmed form redirects", async () => {
        openConfirmDialog.mockResolvedValue(true)
        submitForm()
        await flush()

        expect(beforeVisit().defaultPrevented).toBe(false)
        expect(openConfirmDialog).toHaveBeenCalledTimes(1)
      })
    })
  })

  it("leaves clicks on links inside it to the visit guard", () => {
    makeDirty()
    const event = new MouseEvent("click", { bubbles: true, cancelable: true })
    document.querySelector("#inner_link").dispatchEvent(event)

    expect(event.defaultPrevented).toBe(false)
    expect(openConfirmDialog).not.toHaveBeenCalled()
  })

  describe("disconnectedCallback", () => {
    it("stops guarding", () => {
      makeDirty()
      component.remove()
      document.querySelector("#outer").append(form)

      const event = submitForm()

      expect(event.defaultPrevented).toBe(false)
      expect(openConfirmDialog).not.toHaveBeenCalled()
    })
  })
})

describe("turbo:before-visit", () => {
  const flush = () => new Promise((resolve) => setTimeout(resolve))
  const url = "http://localhost/admin/languages?page=2#top"

  const beforeVisit = () => {
    const event = new CustomEvent("turbo:before-visit", {
      bubbles: true,
      cancelable: true,
      detail: { url }
    })
    document.dispatchEvent(event)
    return event
  }

  beforeEach(() => {
    vi.clearAllMocks()
    document.dispatchEvent(new Event("turbo:load"))
    vi.spyOn(Turbo, "visit").mockImplementation(() => {})
    document.body.innerHTML = `<alchemy-element-editor></alchemy-element-editor>`
  })

  afterEach(() => {
    Turbo.visit.mockRestore()
    window.onbeforeunload = null
  })

  it("lets the visit through without unsaved changes", () => {
    const event = beforeVisit()

    expect(event.defaultPrevented).toBe(false)
    expect(openConfirmDialog).not.toHaveBeenCalled()
  })

  describe("with unsaved changes", () => {
    beforeEach(() => {
      document.querySelector("alchemy-element-editor").classList.add("dirty")
    })

    it("prevents the visit and asks for confirmation", () => {
      openConfirmDialog.mockResolvedValue(false)
      const event = beforeVisit()

      expect(event.defaultPrevented).toBe(true)
      expect(openConfirmDialog).toHaveBeenCalledWith(
        "page_dirty_notice",
        expect.any(Object)
      )
    })

    it("visits the full url once confirmed", async () => {
      openConfirmDialog.mockResolvedValue(true)
      beforeVisit()
      await flush()

      expect(Turbo.visit).toHaveBeenCalledWith(url)
    })

    it("does not visit when the confirmation is cancelled", async () => {
      openConfirmDialog.mockResolvedValue(false)
      beforeVisit()
      await flush()

      expect(Turbo.visit).not.toHaveBeenCalled()
    })

    it("does not ask again for the confirmed visit", async () => {
      openConfirmDialog.mockResolvedValue(true)
      beforeVisit()
      await flush()

      expect(beforeVisit().defaultPrevented).toBe(false)
      expect(openConfirmDialog).toHaveBeenCalledTimes(1)
    })

    it("asks again once the next page has loaded", async () => {
      openConfirmDialog.mockResolvedValue(true)
      beforeVisit()
      await flush()
      document.dispatchEvent(new Event("turbo:load"))

      expect(beforeVisit().defaultPrevented).toBe(true)
      expect(openConfirmDialog).toHaveBeenCalledTimes(2)
    })

    it("clears the unload warning once confirmed", async () => {
      window.onbeforeunload = () => {}
      openConfirmDialog.mockResolvedValue(true)
      beforeVisit()
      await flush()

      expect(window.onbeforeunload).toBeFalsy()
    })
  })
})
