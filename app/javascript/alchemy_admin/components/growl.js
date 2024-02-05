class Growl extends HTMLElement {
  connectedCallback() {
    Alchemy.growl(
      this.getAttribute("message"),
      this.getAttribute("type") || "notice"
    )
  }
}

customElements.define("alchemy-growl", Growl)
