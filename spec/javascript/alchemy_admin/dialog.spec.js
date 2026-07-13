import { vi } from "vitest"
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
})
