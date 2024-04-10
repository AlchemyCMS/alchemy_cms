import "alchemy_admin/components/action"
import { renderComponent } from "./component.helper"
import { closeCurrentDialog } from "alchemy_admin/dialog"
import * as PreviewWindow from "alchemy_admin/components/preview_window"
import IngredientAnchorLink from "alchemy_admin/ingredient_anchor_link"

jest.mock("alchemy_admin/dialog", () => {
  return {
    __esModule: true,
    closeCurrentDialog: jest.fn()
  }
})

jest.mock("alchemy_admin/components/preview_window", () => {
  return {
    __esModule: true,
    reloadPreview: jest.fn()
  }
})

jest.mock("alchemy_admin/ingredient_anchor_link", () => {
  return {
    __esModule: true,
    default: {
      updateIcon: jest.fn()
    }
  }
})

describe("alchemy-action", () => {
  beforeEach(jest.clearAllMocks)

  it("call reloadPreview function", () => {
    renderComponent(
      "alchemy-action",
      `<alchemy-action name="reloadPreview"></alchemy-action>`
    )
    expect(PreviewWindow.reloadPreview).toBeCalled()
  })

  it("call updateAnchorIcon function with parameter", () => {
    renderComponent(
      "alchemy-action",
      `<alchemy-action name="updateAnchorIcon" params="[123, true]"></alchemy-action>`
    )
    expect(IngredientAnchorLink.updateIcon).toBeCalledWith(123, true)
  })

  it("call closeCurrentDialog function ", () => {
    renderComponent(
      "alchemy-action",
      `<alchemy-action name="closeCurrentDialog"></alchemy-action>`
    )
    expect(closeCurrentDialog).toBeCalled()
  })
})
