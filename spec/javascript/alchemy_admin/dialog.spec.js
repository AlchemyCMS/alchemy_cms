import { vi } from "vitest"
import { Dialog } from "alchemy_admin/dialog"

vi.mock("alchemy_admin/spinner")
vi.mock("alchemy_admin/hotkeys")

describe("Dialog", () => {
  let dialog = undefined

  beforeEach(() => {
    document.body.innerHTML = ""
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
})
