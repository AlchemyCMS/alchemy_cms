import PictureSelector from "alchemy_admin/picture_selector"

describe("PictureSelector", () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div class="toolbar_buttons">
        <a id="select_all_pictures"></a>
      </div>
      <div class="selected_item_tools hidden"></div>
      <div id="picture_archive">
        <div class="picture_thumbnail">
          <span class="picture_tool select">
            <input type="checkbox" name="picture_ids[]" id="checkbox_1" value="1">
          </span>
        </div>
        <div class="picture_thumbnail">
          <span class="picture_tool select">
            <input type="checkbox" name="picture_ids[]" id="checkbox_2" value="1">
          </span>
        </div>
      </div>
    `

    PictureSelector()
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
})
