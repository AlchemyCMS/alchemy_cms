import { vi } from "vitest"

vi.mock("alchemy_admin/dialog", () => ({
  __esModule: true,
  closeCurrentDialog: vi.fn()
}))

vi.mock("alchemy_admin/components/preview_window", () => ({
  __esModule: true,
  reloadPreview: vi.fn()
}))

vi.mock("alchemy_admin/fixed_elements", () => ({
  __esModule: true,
  removeTab: vi.fn()
}))

vi.mock("alchemy_admin/ingredient_anchor_link", () => ({
  __esModule: true,
  default: { updateIcon: vi.fn() }
}))

vi.mock("alchemy_admin/please_wait_overlay", () => ({
  __esModule: true,
  default: vi.fn()
}))

import { Turbo } from "@hotwired/turbo-rails"
import "alchemy_admin/turbo_stream_actions"
import { closeCurrentDialog } from "alchemy_admin/dialog"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import { removeTab } from "alchemy_admin/fixed_elements"
import IngredientAnchorLink from "alchemy_admin/ingredient_anchor_link"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"

// The actions read their arguments off the <turbo-stream> element via `this`.
function streamElement(attributes = {}) {
  return {
    getAttribute: (name) => attributes[name] ?? null
  }
}

describe("turbo_stream_actions", () => {
  beforeEach(vi.clearAllMocks)

  it("close_current_dialog closes the current dialog", () => {
    Turbo.StreamActions.close_current_dialog.call(streamElement())
    expect(closeCurrentDialog).toBeCalled()
  })

  it("reload_preview reloads the preview", () => {
    Turbo.StreamActions.reload_preview.call(streamElement())
    expect(reloadPreview).toBeCalled()
  })

  it("remove_fixed_element removes the fixed element tab", () => {
    Turbo.StreamActions.remove_fixed_element.call(
      streamElement({ "element-id": "123" })
    )
    expect(removeTab).toBeCalledWith("123")
  })

  it("update_anchor_icon activates the icon", () => {
    Turbo.StreamActions.update_anchor_icon.call(
      streamElement({ "ingredient-id": "123", active: "true" })
    )
    expect(IngredientAnchorLink.updateIcon).toBeCalledWith("123", true)
  })

  it("update_anchor_icon deactivates the icon", () => {
    Turbo.StreamActions.update_anchor_icon.call(
      streamElement({ "ingredient-id": "123", active: "false" })
    )
    expect(IngredientAnchorLink.updateIcon).toBeCalledWith("123", false)
  })

  it("hide_please_wait_overlay hides the overlay", () => {
    Turbo.StreamActions.hide_please_wait_overlay.call(streamElement())
    expect(pleaseWaitOverlay).toBeCalledWith(false)
  })
})
