import { Select } from "alchemy_admin/components/select"

const renderColorOption = (data, escape) => {
  const swatch = data.swatch || data.value
  const colorIndicator =
    data.value === "custom_color"
      ? `<alchemy-icon name="palette"></alchemy-icon>`
      : `<span class="color-indicator" style="--color: ${escape(swatch)}"></span>`

  return `
    <div class="select-color-option">
      ${colorIndicator}
      <span>${escape(data.text)}</span>
    </div>`
}

// A color options select enhanced by Tom Select. It inherits from the shared
// alchemy-select component to reuse the Tom Select setup, renders each option
// and the selected item with a color swatch (or the custom-color icon), and
// enables the adjacent color picker while a custom color is selected.
export class ColorSelect extends Select {
  connectedCallback() {
    super.connectedCallback()
    this.addEventListener("change", this.#onChange)
  }

  disconnectedCallback() {
    super.disconnectedCallback()
    this.removeEventListener("change", this.#onChange)
  }

  get renderers() {
    return {
      item: renderColorOption,
      option: renderColorOption
    }
  }

  #onChange = () => {
    const colorPicker = this.parentElement?.querySelector("input[type='color']")
    if (colorPicker) {
      colorPicker.disabled = this.value !== "custom_color"
    }
  }
}

customElements.define("alchemy-color-select", ColorSelect, {
  extends: "select"
})

// Free-form color input used when no color options are configured. Keeps the
// text field and the native color picker in sync and enables the picker.
export class ColorInput extends HTMLElement {
  connectedCallback() {
    this.colorInput?.addEventListener("input", this)
    this.textInput?.addEventListener("input", this)
    if (this.colorInput) {
      this.colorInput.disabled = false
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

  get colorInput() {
    return this.querySelector("input[type='color']")
  }

  get textInput() {
    return this.querySelector("input[type='text']")
  }
}

customElements.define("alchemy-color-input", ColorInput)
