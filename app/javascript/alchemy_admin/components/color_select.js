const formatItem = (object) => {
  const color = object.element[0].value
  const style = color === "custom_color" ? "" : `style="--color: ${color}"`
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
