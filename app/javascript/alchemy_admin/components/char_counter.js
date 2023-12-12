/**
 * Show the character counter below input fields and textareas
 */
import { AlchemyHTMLElement } from "alchemy_admin/components/alchemy_html_element"
import { translate } from "alchemy_admin/i18n"

class CharCounter extends AlchemyHTMLElement {
  static properties = {
    maxChars: { default: 60 }
  }
  connected() {
    this.translation = translate("allowed_chars", this.maxChars)
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
    this.display.classList.toggle("too-long", charLength > this.maxChars)
  }
}

customElements.define("alchemy-char-counter", CharCounter)
