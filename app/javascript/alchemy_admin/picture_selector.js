import { on } from "alchemy_admin/utils/events"

function toggleCheckboxes(state) {
  document
    .querySelectorAll(".picture_tool.select input[type='checkbox']")
    .forEach((checkbox) => {
      checkbox.checked = state
      checkbox.closest(".picture_thumbnail").classList.toggle("active", state)
    })
}

function checkedInputs() {
  return document.querySelectorAll("#picture_archive input:checked")
}

function editMultiplePicturesUrl(href) {
  const searchParameters = new URLSearchParams()
  checkedInputs().forEach((entry) =>
    searchParameters.append(entry.name, entry.value)
  )
  const url = href + "?" + searchParameters.toString()

  return url
}

/**
 * Multiple picture select handler for the picture archive.
 */
export default function PictureSelector() {
  const selectAllButton = document.querySelector("#select_all_pictures")
  const selectedItemTools = document.querySelector(".selected_item_tools")

  on("click", ".toolbar_buttons", "a#select_all_pictures", (event) => {
    event.preventDefault()

    selectAllButton.classList.toggle("active")

    const state = selectAllButton.classList.contains("active")

    toggleCheckboxes(state)

    selectedItemTools.classList.toggle("hidden", !state)
  })

  // make the item toolbar visible and show the checkbox also if it is not hovered anymore
  on("change", ".picture_tool.select", "input", (event) => {
    selectedItemTools.classList.toggle("hidden", checkedInputs().length === 0)

    const parentElementClassList = event.target.parentElement.classList
    const checked = event.target.checked

    parentElementClassList.toggle("visible", checked)
  })

  // open the edit view in a dialog modal
  on("click", ".selected_item_tools", "a#edit_multiple_pictures", (event) => {
    event.preventDefault()

    const url = editMultiplePicturesUrl(event.target.href)

    Alchemy.openDialog(url, {
      title: event.target.title,
      size: "400x295"
    })
  })
}
