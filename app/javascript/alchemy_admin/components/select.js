class Select extends HTMLSelectElement {
  #select2Element = undefined

  connectedCallback() {
    this.classList.add("alchemy_selectbox")

    this.#select2Element = $(this).select2({
      minimumResultsForSearch: 5,
      dropdownAutoWidth: true
    })
  }

  set data(data) {
    let selected = this.value
    // remove all previous entries except the default please select entry which has no value or is selected
    const emptyOption =
      this.options[0]?.value === ""
        ? this.options[0].cloneNode(true)
        : undefined

    this.innerHTML = ""
    if (emptyOption) {
      this.add(emptyOption)
    }
    // add the new options to the select
    data.forEach((item) => {
      const option = new Option(item.text, item.id, false, item.id === selected)
      this.add(option)
    })

    // inform Select2 to update
    this.#select2Element.trigger("change")
  }
}

customElements.define("alchemy-select", Select, { extends: "select" })
