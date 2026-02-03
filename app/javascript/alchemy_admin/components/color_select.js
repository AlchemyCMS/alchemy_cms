const formatItem = (object) => {
  const optionEl = object.element[0]
  const swatch = optionEl.dataset.swatch || optionEl.value
  const style =
    optionEl.value === "custom_color" ? "" : `style="--color: ${swatch}"`
  return `
    <div class="select-color-option">
      <span class="color-indicator" ${style}></span>
      <span>${object.text}</span>
    </div>`
}

class ColorSelect extends HTMLElement {
  connectedCallback() {
    if (this.select) {
      this.#initializeSelect2()
      $(this.select).on("change", (event) =>
        this.#toggleColorPicker(event.val === "custom_color")
      )
    } else {
      this.#toggleColorPicker(true)
    }
  }

  #initializeSelect2() {
    this.select.classList.add("alchemy_selectbox")
    const options = {
      minimumResultsForSearch: 10,
      formatResult: formatItem,
      formatSelection: formatItem
    }
    $(this.select).select2(options)
  }

  #toggleColorPicker(enabled = true) {
    this.colorInput.disabled = !enabled
  }

  get colorInput() {
    return this.querySelector("input[type='color']")
  }

  get select() {
    return this.querySelector("select")
  }
}

customElements.define("alchemy-color-select", ColorSelect)
