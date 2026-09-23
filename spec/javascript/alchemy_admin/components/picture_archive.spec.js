import { vi } from "vitest"
import "alchemy_admin/components/picture_archive"
import { openDialog } from "alchemy_admin/dialog"

vi.mock("alchemy_admin/dialog", () => ({
  openDialog: vi.fn()
}))

describe("alchemy-picture-archive", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div class="toolbar_buttons">
        <a id="select_all_pictures"></a>
      </div>
      <alchemy-picture-archive>
        <div class="selected_item_tools hidden">
          <a id="edit_multiple_pictures" href="http://localhost/admin/pictures/edit_multiple" title="Edit multiple pictures"></a>
        </div>
        <div class="picture_thumbnail">
          <span class="picture_tool select">
            <input type="checkbox" name="picture_ids[]" id="checkbox_1" value="1">
          </span>
        </div>
        <div class="picture_thumbnail">
          <span class="picture_tool select">
            <input type="checkbox" name="picture_ids[]" id="checkbox_2" value="2">
          </span>
        </div>
      </alchemy-picture-archive>
    `
  })

  it("selects/unselects all images and toggles selection toolbar visibility", () => {
    const selectAllButton = document.querySelector("#select_all_pictures")
    const checkboxOne = document.querySelector("#checkbox_1")
    const checkboxTwo = document.querySelector("#checkbox_2")
    const selectionToolbar = document.querySelector(".selected_item_tools")

    selectAllButton.click()

    expect(selectAllButton.classList.contains("active")).toBeTruthy()
    expect(selectionToolbar.classList.contains("hidden")).toBeFalsy()
    expect(checkboxOne.checked).toBeTruthy()
    expect(checkboxTwo.checked).toBeTruthy()

    selectAllButton.click()

    expect(selectAllButton.classList.contains("active")).toBeFalsy()
    expect(selectionToolbar.classList.contains("hidden")).toBeTruthy()
    expect(checkboxOne.checked).toBeFalsy()
    expect(checkboxTwo.checked).toBeFalsy()
  })

  it("marks the thumbnails as active while all images are selected", () => {
    const selectAllButton = document.querySelector("#select_all_pictures")
    const thumbnail = document.querySelector(".picture_thumbnail")

    selectAllButton.click()
    expect(thumbnail.classList.contains("active")).toBeTruthy()

    selectAllButton.click()
    expect(thumbnail.classList.contains("active")).toBeFalsy()
  })

  it("toggles selection toolbar visibility when one image is selected/unselected", () => {
    const selectionToolbar = document.querySelector(".selected_item_tools")
    const checkboxParent = document.querySelector(".picture_tool")
    const checkbox = document.querySelector("#checkbox_1")

    checkbox.click()

    expect(selectionToolbar.classList.contains("hidden")).toBeFalsy()
    expect(checkboxParent.classList.contains("visible")).toBeTruthy()

    checkbox.click()

    expect(selectionToolbar.classList.contains("hidden")).toBeTruthy()
    expect(checkboxParent.classList.contains("visible")).toBeFalsy()
  })

  it("opens the edit multiple dialog with the selected picture ids", () => {
    document.querySelector("#checkbox_2").click()
    document.querySelector("#edit_multiple_pictures").click()

    expect(openDialog).toHaveBeenCalledWith(
      "http://localhost/admin/pictures/edit_multiple?picture_ids%5B%5D=2",
      { title: "Edit multiple pictures", size: "400x295" }
    )
  })

  it("stops listening for the select all button once disconnected", () => {
    const selectAllButton = document.querySelector("#select_all_pictures")
    const checkbox = document.querySelector("#checkbox_1")

    document.querySelector("alchemy-picture-archive").remove()
    selectAllButton.click()

    expect(checkbox.checked).toBeFalsy()
  })
})
