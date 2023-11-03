class Menubar extends HTMLElement {
  constructor() {
    super()
    const template = this.querySelector("template")
    const attachedShadowRoot = this.attachShadow({ mode: "open" })
    attachedShadowRoot.appendChild(template.content.cloneNode(true))
  }
}

customElements.define("alchemy-menubar", Menubar)
