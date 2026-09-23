import { vi } from "vitest"
import { Turbo } from "@hotwired/turbo-rails"
import { Dialog } from "alchemy_admin/dialog"

vi.mock("alchemy_admin/spinner")
vi.mock("alchemy_admin/hotkeys")

describe("Dialog", () => {
  let dialog = undefined

  beforeEach(() => {
    document.body.innerHTML = ""
    document.body.className = ""
    // Run requestAnimationFrame callbacks synchronously so the autofocus
    // behaviour can be asserted without waiting for a real frame.
    vi.spyOn(window, "requestAnimationFrame").mockImplementation((cb) => {
      cb()
      return 0
    })
    dialog = new Dialog("/admin/some/path")
  })

  afterEach(() => {
    vi.restoreAllMocks()
    vi.unstubAllGlobals()
  })

  describe("init", () => {
    it("focuses the element with an autofocus attribute", () => {
      dialog.dialog_body.innerHTML =
        '<input id="without-focus"><input id="with-focus" autofocus>'

      dialog.init()

      expect(document.activeElement).toEqual(
        dialog.dialog_body.querySelector("#with-focus")
      )
    })

    it("focuses the form's submit button when no autofocus element is present", () => {
      dialog.dialog_body.innerHTML =
        '<form><input id="field"><button type="submit" id="submit">Go</button></form>'

      dialog.init()

      expect(document.activeElement).toEqual(
        dialog.dialog_body.querySelector("#submit")
      )
    })

    it("does not change focus without an autofocus element or form submit button", () => {
      dialog.dialog_body.innerHTML = '<input id="without-focus">'

      expect(() => dialog.init()).not.toThrow()
      expect(dialog.dialog_body.contains(document.activeElement)).toBe(false)
    })
  })

  describe("scroll lock", () => {
    const closeAndFinishTransition = (dialogToClose) => {
      dialogToClose.close()
      dialogToClose.dialog_container.dispatchEvent(new Event("transitionend"))
    }

    beforeEach(() => {
      // open() loads the content via fetch, which is irrelevant here. Keep it
      // pending so the body is never replaced.
      vi.stubGlobal(
        "fetch",
        vi.fn(() => new Promise(() => {}))
      )
    })

    it("keeps the scroll lock until the last of the nested dialogs is closed", () => {
      const outer = new Dialog("/outer")
      const inner = new Dialog("/inner")

      outer.open()
      inner.open()

      expect(document.body.classList.contains("prevent-scrolling")).toBe(true)

      // The outer dialog is still open, so the page must not scroll behind it.
      closeAndFinishTransition(inner)

      expect(document.body.classList.contains("prevent-scrolling")).toBe(true)

      closeAndFinishTransition(outer)

      expect(document.body.classList.contains("prevent-scrolling")).toBe(false)
    })
  })

  describe("cancel event", () => {
    beforeEach(() => {
      vi.stubGlobal(
        "fetch",
        vi.fn(() => new Promise(() => {}))
      )
      dialog.open()
    })

    it("closes when the container's own cancel event fires (Esc key)", () => {
      const close = vi.spyOn(dialog, "close")

      dialog.dialog_container.dispatchEvent(new Event("cancel"))

      expect(close).toHaveBeenCalled()
    })

    it("stays open when a nested file input's cancel event bubbles up", () => {
      dialog.dialog_body.innerHTML = '<input type="file">'
      const close = vi.spyOn(dialog, "close")

      dialog.dialog_body
        .querySelector("input")
        .dispatchEvent(new Event("cancel", { bubbles: true }))

      expect(close).not.toHaveBeenCalled()
    })
  })

  describe("load", () => {
    const respondWith = ({ status, contentType, body }) => {
      vi.stubGlobal(
        "fetch",
        vi.fn(() =>
          Promise.resolve({
            ok: status < 400,
            status,
            statusText: "Unauthorized",
            headers: { get: () => contentType },
            text: () => Promise.resolve(body)
          })
        )
      )
    }

    it("renders a turbo stream response instead of showing the error", async () => {
      respondWith({
        status: 401,
        contentType: "text/vnd.turbo-stream.html; charset=utf-8",
        body: '<turbo-stream action="dialog_visit" url="/admin/login"></turbo-stream>'
      })
      const renderStreamMessage = vi.spyOn(Turbo, "renderStreamMessage")

      dialog.open()
      await vi.waitFor(() => expect(renderStreamMessage).toHaveBeenCalled())

      expect(renderStreamMessage).toHaveBeenCalledWith(
        '<turbo-stream action="dialog_visit" url="/admin/login"></turbo-stream>'
      )
      expect(dialog.dialog_body.innerHTML).not.toContain("alchemy-message")
    })

    it("shows the error for a failed html response", async () => {
      respondWith({
        status: 500,
        contentType: "text/html; charset=utf-8",
        body: "Boom"
      })

      dialog.open()
      await vi.waitFor(() =>
        expect(dialog.dialog_body.innerHTML).toContain("alchemy-message")
      )
    })
  })
})
