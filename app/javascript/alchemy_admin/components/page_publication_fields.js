// Handles the page publication date fields
export class PagePublicationFields extends HTMLElement {
  connectedCallback() {
    const public_on_field = this.querySelector("#page_public_on")
    const public_until_field = this.querySelector("#page_public_until")
    const publication_date_fields = this.querySelector(
      ".page-publication-date-fields"
    )
    const public_field = this.querySelector("#page_public")

    if (!public_field) return

    public_field.addEventListener("click", function (evt) {
      const checkbox = evt.target
      const now = new Date()

      if (checkbox.checked) {
        publication_date_fields.classList.remove("hidden")
        public_on_field._flatpickr.setDate(now)
      } else {
        publication_date_fields.classList.add("hidden")
        public_on_field.value = ""
      }
      public_until_field.value = ""
    })
  }
}

customElements.define("alchemy-page-publication-fields", PagePublicationFields)
