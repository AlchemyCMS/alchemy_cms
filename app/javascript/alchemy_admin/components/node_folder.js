/**
 * Custom element for the fold toggle of a menu node
 * Renders the fold arrow and keeps it in sync with the folded attribute
 */
export class AlchemyNodeFolder extends HTMLElement {
  static get observedAttributes() {
    return ["folded"]
  }

  connectedCallback() {
    this.innerHTML = `
      <button class="node_folder icon_button">
        <alchemy-icon name="${this.iconName}"></alchemy-icon>
      </button>
    `
  }

  attributeChangedCallback() {
    // Fires before connectedCallback for attributes present in the markup
    this.icon?.setAttribute("name", this.iconName)
  }

  get icon() {
    return this.querySelector("alchemy-icon")
  }

  get iconName() {
    return this.folded ? "arrow-right-s" : "arrow-down-s"
  }

  get folded() {
    return this.hasAttribute("folded")
  }
}

customElements.define("alchemy-node-folder", AlchemyNodeFolder)
