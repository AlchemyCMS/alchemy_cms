const DISMISS_DELAY = 5000

class Message extends HTMLElement {
  #message

  constructor() {
    super()
    this.#message = this.innerHTML
    if (this.dismissable || this.type === "error") {
      this.addEventListener("click", this)
    }
  }

  handleEvent(event) {
    if (event.type === "click") {
      this.dismiss()
    }
  }

  connectedCallback() {
    this.innerHTML = `
      <alchemy-icon name="${this.iconName}"></alchemy-icon>
      ${this.dismissable && this.type === "error" ? '<alchemy-icon name="close"></alchemy-icon>' : ""}
      ${this.#message}
    `
    if (this.dismissable && this.type !== "error") {
      setTimeout(() => {
        this.dismiss()
      }, this.delay)
    }
  }

  dismiss() {
    this.addEventListener("transitionend", () => this.remove())
    this.classList.add("dismissed")
  }

  get dismissable() {
    return this.hasAttribute("dismissable")
  }

  get type() {
    return this.getAttribute("type") || "notice"
  }

  get delay() {
    return parseInt(this.getAttribute("delay") || DISMISS_DELAY)
  }

  get iconName() {
    switch (this.type) {
      case "warning":
      case "warn":
      case "alert":
        return "alert"
      case "notice":
        return "check"
      case "info":
      case "hint":
        return "information"
      case "error":
        return "bug"
      default:
        return this.type
    }
  }
}

customElements.define("alchemy-message", Message)
