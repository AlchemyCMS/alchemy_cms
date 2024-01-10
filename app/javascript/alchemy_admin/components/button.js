import Spinner from "alchemy_admin/spinner"

class Button extends HTMLButtonElement {
  connectedCallback() {
    if (this.form) {
      this.form.addEventListener("submit", this)

      if (this.form.dataset.remote == "true") {
        this.form.addEventListener("ajax:complete", this)
      }
    } else {
      console.warn("No form for button found!", this)
    }
  }

  handleEvent(event) {
    switch (event.type) {
      case "submit":
        const isDisabled = this.getAttribute("disabled") === "disabled"

        if (isDisabled) {
          event.preventDefault()
          event.stopPropagation()
        } else {
          this.disable()
        }
        break
      case "ajax:complete":
        this.enable()
        break
    }
  }

  disable() {
    const spinner = new Spinner("small")
    const rect = this.getBoundingClientRect()

    this.dataset.initialButtonText = this.innerHTML
    this.setAttribute("disabled", "disabled")
    this.setAttribute("tabindex", "-1")
    this.classList.add("disabled")
    this.style.width = `${rect.width}px`
    this.style.height = `${rect.height}px`
    this.innerHTML = "&nbsp;"

    spinner.spin(this)
  }

  enable() {
    this.classList.remove("disabled")
    this.removeAttribute("disabled")
    this.removeAttribute("tabindex")
    this.style.width = null
    this.style.height = null
    this.innerHTML = this.dataset.initialButtonText
  }
}

customElements.define("alchemy-button", Button, { extends: "button" })
