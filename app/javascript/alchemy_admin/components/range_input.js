// Shows the value of the range input in the output element next to it
class RangeInput extends HTMLElement {
  connectedCallback() {
    this.rangeInput?.addEventListener("input", this)
  }

  disconnectedCallback() {
    this.rangeInput?.removeEventListener("input", this)
  }

  handleEvent() {
    this.output.value = this.rangeInput.value
  }

  get rangeInput() {
    return this.querySelector("input[type='range']")
  }

  get output() {
    return this.querySelector("output")
  }
}

customElements.define("alchemy-range-input", RangeInput)
