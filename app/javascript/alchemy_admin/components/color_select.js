const formatItem = (object) => {
  const optionEl = object.element[0]
  const swatch = optionEl.dataset.swatch || optionEl.value
  const customColor = optionEl.value === "custom_color"
  const colorIndicator = customColor
    ? `<alchemy-icon name="palette"></alchemy-icon>`
    : `<span class="color-indicator" style="--color: ${swatch}"></span>`

  return `
    <div class="select-color-option">
      ${colorIndicator}
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
      this.colorInput?.addEventListener("input", this)
      this.textInput?.addEventListener("input", this)
      this.#toggleColorPicker(true)
    }
  }

  handleEvent(event) {
    switch (event.target) {
      case this.colorInput:
        this.textInput.value = this.colorInput.value
        break
      case this.textInput:
        this.colorInput.value = this.textInput.value
        break
    }
  }

  disconnectedCallback() {
    this.colorInput?.removeEventListener("input", this)
    this.textInput?.removeEventListener("input", this)
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

  get textInput() {
    return this.querySelector("input[type='text']")
  }

  get select() {
    return this.querySelector("select")
  }
}

customElements.define("alchemy-color-select", ColorSelect)
