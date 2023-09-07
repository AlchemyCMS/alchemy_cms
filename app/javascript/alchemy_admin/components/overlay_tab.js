import { AlchemyHTMLElement } from "./alchemy_html_element"

class OverlayTab extends AlchemyHTMLElement {
  static properties = {
    title: { default: "" }
  }

  connected() {
    if (!this.id) {
      // generate an id, if it isn't given
      this.id = "overlay_tab_" + Math.floor(100000 + Math.random() * 900000)
    }
  }

  render() {
    return this.initialContent
  }
}
customElements.define("alchemy-overlay-tab", OverlayTab)
