class Select extends HTMLSelectElement {
  #select2Element

  connectedCallback() {
    this.classList.add("alchemy_selectbox")

    this.#select2Element = $(this).select2({
      minimumResultsForSearch: 5,
      dropdownAutoWidth: true,
      allowClear: !!this.allowClear
    })

    if (!this.allowClear) {
      this.#select2Element
        .prev(".select2-container")
        .find(".select2-search-choice-close")
        .remove()
    }
  }

  enable() {
    this.removeAttribute("disabled")
    this.#updateSelect2()
  }

  disable() {
    this.setAttribute("disabled", "disabled")
    this.#updateSelect2()
  }

  setOptions(data, prompt = undefined) {
    let selectedValue = this.value

    // reset the old options and insert the placeholder(s) first
    this.innerHTML = ""
    if (prompt) {
      this.add(new Option(prompt, ""))
    }

    // add the new options to the select
    data.forEach((item) => {
      this.add(new Option(item.text, item.id, false, item.id === selectedValue))
    })

    this.#updateSelect2()
  }

  /**
   * inform Select2 to update
   */
  #updateSelect2() {
    this.#select2Element.trigger("change")
  }

  get allowClear() {
    return this.dataset.hasOwnProperty("allowClear")
  }
}

customElements.define("alchemy-select", Select, { extends: "select" })
