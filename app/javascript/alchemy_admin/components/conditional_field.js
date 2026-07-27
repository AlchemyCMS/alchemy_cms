/**
 * Shows its fields only while the controlling checkbox is checked.
 *
 * Hidden fields are disabled as well, so they are not submitted and the stored
 * value is left untouched while the condition does not apply. A disabled
 * control (a fixed page attribute for example) keeps the fields disabled.
 *
 *   <alchemy-conditional-field control="page_restricted">
 *     <input type="text" name="page[foo]">
 *   </alchemy-conditional-field>
 */
class ConditionalField extends HTMLElement {
  connectedCallback() {
    this.control?.addEventListener("change", this)
    this.toggle()
  }

  disconnectedCallback() {
    this.control?.removeEventListener("change", this)
  }

  handleEvent(event) {
    if (event.type === "change") this.toggle()
  }

  toggle() {
    const active = !!this.control?.checked && !this.control.disabled

    this.hidden = !active
    this.fields.forEach((field) => {
      // Custom elements like alchemy-select need their own API to keep their
      // rendered control in sync, but might not be upgraded yet.
      if (typeof field.disable === "function") {
        active ? field.enable() : field.disable()
      } else {
        field.disabled = !active
      }
    })
  }

  get control() {
    return document.getElementById(this.getAttribute("control"))
  }

  get fields() {
    return this.querySelectorAll("input, select, textarea")
  }
}

customElements.define("alchemy-conditional-field", ConditionalField)
