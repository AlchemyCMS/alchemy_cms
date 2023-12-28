class UnlinkButton extends HTMLButtonElement {
  constructor() {
    super()
    this.addEventListener("click", this)
    this.classList.add("icon_button")
    // Prevent accidental form submits if this component is wrapped inside a form
    this.setAttribute("type", "button")
    this.linked = this.linked
    this.innerHTML = '<i class="icon ri-link-unlink-m ri-fw"></i>'
  }

  handleEvent(event) {
    if (this.linked) {
      this.linked = false
      this.blur()
      this.dispatchEvent(new CustomEvent("alchemy:unlink", { bubbles: true }))
    }
    event.preventDefault()
  }

  set linked(isLinked) {
    if (isLinked) {
      this.classList.replace("disabled", "linked")
      this.removeAttribute("tabindex")
    } else {
      this.classList.replace("linked", "disabled")
      this.setAttribute("tabindex", "-1")
    }
  }

  get linked() {
    return this.classList.contains("linked")
  }
}

customElements.define("alchemy-unlink-button", UnlinkButton, {
  extends: "button"
})
