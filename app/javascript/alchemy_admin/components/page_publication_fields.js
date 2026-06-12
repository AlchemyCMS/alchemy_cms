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
    const date = new Date()
    const now = new Date(
      date.getTime() - date.getTimezoneOffset() * 60000
    ).toISOString()

    if (checkbox.checked) {
      this.publicationDateFields.classList.remove("hidden")
      this.publicOnPicker.value = now.substring(0, now.indexOf("T") + 6)
    } else {
      this.publicationDateFields.classList.add("hidden")
      this.publicOnPicker.value = ""
    }
    this.publicUntilPicker.value = ""
  }

  get publicField() {
    return this.querySelector("#page_public")
  }

  get publicOnPicker() {
    return this.querySelector("input#page_public_on")
  }

  get publicUntilPicker() {
    return this.querySelector("input#page_public_until")
  }

  get publicationDateFields() {
    return this.querySelector(".page-publication-date-fields")
  }
}

customElements.define("alchemy-page-publication-fields", PagePublicationFields)
