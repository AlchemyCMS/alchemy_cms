import { on } from "alchemy_admin/utils/events"

/**
 * Multiple picture select handler for the picture archive.
 */
export default function PictureSelector() {
  const selectedItemTools = document.querySelector(".selected_item_tools")
  const checkedInputs = () =>
    document.querySelectorAll("#picture_archive input:checked")

  // make the item toolbar visible and show the checkbox also if it is not hovered anymore
  on("change", ".picture_tool.select", "input", (event) => {
    selectedItemTools.style.display =
      checkedInputs().length > 0 ? "block" : "none"

    const parentElementClassList = event.target.parentElement.classList
    const checked = event.target.checked

    parentElementClassList.toggle("visible", checked)
    parentElementClassList.toggle("hidden", !checked)
  })

  // open the edit view in a dialog modal
  on("click", ".selected_item_tools", "a#edit_multiple_pictures", (event) => {
    event.preventDefault()

    const searchParameters = new URLSearchParams()
    checkedInputs().forEach((entry) =>
      searchParameters.append(entry.name, entry.value)
    )
    const url = event.target.href + "?" + searchParameters.toString()

    Alchemy.openDialog(url, {
      title: event.target.title,
      size: "400x295"
    })
  })
}
