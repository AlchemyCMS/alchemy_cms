class ClearScheduleButton extends HTMLButtonElement {
  connectedCallback() {
    this.addEventListener("click", this)
  }

  disconnectedCallback() {
    this.removeEventListener("click", this)
  }

  handleEvent() {
    this.form
      ?.querySelectorAll('input[type="datetime-local"]')
      .forEach((input) => {
        input.value = ""
      })
  }
}

customElements.define("alchemy-clear-schedule-button", ClearScheduleButton, {
  extends: "button"
})
