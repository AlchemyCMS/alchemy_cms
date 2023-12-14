import { AlchemyHTMLElement } from "alchemy_admin/components/alchemy_html_element"

class Overlay extends AlchemyHTMLElement {
  render() {
    return `
        <alchemy-spinner></alchemy-spinner>
        <div id="overlay_text_box">
            <span id="overlay_text">${this.getAttribute("text")}</span>
        </div>
        `
  }

  set show(value) {
    this.style.setProperty("display", value ? "block" : "none")
  }
}

customElements.define("alchemy-overlay", Overlay)
