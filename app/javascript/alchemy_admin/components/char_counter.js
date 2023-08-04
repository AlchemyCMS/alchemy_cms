/**
 * Show the character counter below input fields and textareas
 */
class CharCounter extends HTMLElement {
  constructor() {
    super()

    this.maxChar = this.dataset.count
    this.translation = Alchemy.t("allowed_chars", this.maxChar)
    this.formField = this.getFormField()

    if (this.formField) {
      this.createDisplayElement()
      this.countCharacters()
      this.formField.addEventListener("keyup", () => this.countCharacters()) // add arrow function to get a implicit this - binding
    }
  }

  getFormField() {
    const formFields = this.querySelectorAll("input, textarea")
    return formFields.length > 0 ? formFields[0] : undefined
  }

  createDisplayElement() {
    this.display = document.createElement("small")
    this.display.className = "alchemy-char-counter"
    this.formField.after(this.display)
  }

  countCharacters() {
    const charLength = this.formField.value.length
    this.display.textContent = `${charLength} ${this.translation}`
    this.display.classList.toggle("too-long", charLength > this.maxChar)
  }
}

customElements.define("alchemy-char-counter", CharCounter)
