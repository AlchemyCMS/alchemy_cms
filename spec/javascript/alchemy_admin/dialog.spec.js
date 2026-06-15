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
      dialog.dialog_body.html(
        '<input id="without-focus"><input id="with-focus" autofocus>'
      )

      dialog.init()

      expect(document.activeElement).toEqual(
        dialog.dialog_body.find("#with-focus")[0]
      )
    })

    it("does not change focus when no autofocus element is present", () => {
      dialog.dialog_body.html('<input id="without-focus">')

      expect(() => dialog.init()).not.toThrow()
      expect(document.activeElement).not.toEqual(
        dialog.dialog_body.find("#without-focus")[0]
      )
    })
  })
})
