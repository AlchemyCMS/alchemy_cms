// Handles the page publication date fields
export class PagePublicationFields extends HTMLElement {
  connectedCallback() {
    this.publicField?.addEventListener("click", this.#onClick)
  }

  disconnectedCallback() {
    this.publicField?.removeEventListener("click", this.#onClick)
  }

  #onClick = (evt) => {
    const checkbox = evt.target
    const now = new Date()

    if (checkbox.checked) {
      this.publicationDateFields.classList.remove("hidden")
      this.publicOnPicker.flatpickr.setDate(now)
    } else {
      this.publicationDateFields.classList.add("hidden")
      this.publicOnPicker.flatpickr.clear()
    }
    this.publicUntilPicker.flatpickr?.clear()
  }

  get publicField() {
    return this.querySelector("#page_public")
  }

  get publicOnPicker() {
    return this.querySelector("alchemy-datepicker:has(#page_public_on)")
  }

  get publicUntilPicker() {
    return this.querySelector("alchemy-datepicker:has(#page_public_until)")
  }

  get publicationDateFields() {
    return this.querySelector(".page-publication-date-fields")
  }
}

customElements.define("alchemy-page-publication-fields", PagePublicationFields)
