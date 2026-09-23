import { openDialog } from "alchemy_admin/dialog"

// Multiple picture select handler for the picture archive.
export class PictureArchive extends HTMLElement {
  connectedCallback() {
    this.addEventListener("change", this.#onCheckboxChange)
    this.addEventListener("click", this.#onEditMultipleClick)
    // The select all button lives in the toolbar, outside of this element.
    document.addEventListener("click", this.#onSelectAllClick)
  }

  disconnectedCallback() {
    this.removeEventListener("change", this.#onCheckboxChange)
    this.removeEventListener("click", this.#onEditMultipleClick)
    document.removeEventListener("click", this.#onSelectAllClick)
  }

  #onSelectAllClick = (event) => {
    if (!event.target.closest("#select_all_pictures")) {
      return
    }

    event.preventDefault()

    this.selectAllButton.classList.toggle("active")

    const state = this.selectAllButton.classList.contains("active")

    this.#toggleCheckboxes(state)

    this.selectedItemTools.classList.toggle("hidden", !state)
  }

  // make the item toolbar visible and show the checkbox also if it is not hovered anymore
  #onCheckboxChange = (event) => {
    const checkbox = event.target.closest(".picture_tool.select input")

    if (!checkbox) {
      return
    }

    this.selectedItemTools.classList.toggle(
      "hidden",
      this.checkedInputs.length === 0
    )
    checkbox.parentElement.classList.toggle("visible", checkbox.checked)
  }

  // open the edit view in a dialog modal
  #onEditMultipleClick = (event) => {
    const link = event.target.closest("a#edit_multiple_pictures")

    if (!link) {
      return
    }

    event.preventDefault()

    openDialog(this.#editMultiplePicturesUrl(link.href), {
      title: link.title,
      size: "400x295"
    })
  }

  #toggleCheckboxes(state) {
    this.querySelectorAll(
      ".picture_tool.select input[type='checkbox']"
    ).forEach((checkbox) => {
      checkbox.checked = state
      checkbox.closest(".picture_thumbnail").classList.toggle("active", state)
    })
  }

  #editMultiplePicturesUrl(href) {
    const url = new URL(href)

    this.checkedInputs.forEach((entry) =>
      url.searchParams.append(entry.name, entry.value)
    )

    return url.toString()
  }

  get checkedInputs() {
    return this.querySelectorAll("input:checked")
  }

  get selectAllButton() {
    return document.querySelector("#select_all_pictures")
  }

  get selectedItemTools() {
    return this.querySelector(".selected_item_tools")
  }
}

customElements.define("alchemy-picture-archive", PictureArchive)
