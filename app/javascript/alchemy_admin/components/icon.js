class Icon extends HTMLElement {
  static get observedAttributes() {
    return ["name", "size", "icon-style"]
  }

  constructor() {
    super()
    this.spriteUrl = document
      .querySelector('link[rel="preload"][as="image"]')
      .getAttribute("href")
  }

  connectedCallback() {
    this.render()
  }

  attributeChangedCallback() {
    this.render()
  }

  render() {
    const sizeClass = this.size ? ` icon--${this.size}` : ""
    this.innerHTML = `<svg class="icon${sizeClass}"><use href="${this.spriteUrl}#ri-${this.iconName}${this.style}" /></svg>`
  }

  set name(value) {
    this.setAttribute("name", value)
  }

  get iconName() {
    return this.getAttribute("name")
  }

  get size() {
    return this.getAttribute("size")
  }

  get style() {
    const value = this.getAttribute("icon-style")
    switch (value) {
      case "none":
        return ""
      case null:
        return "-line"
      default:
        return `-${value}`
    }
  }
}

customElements.define("alchemy-icon", Icon)
