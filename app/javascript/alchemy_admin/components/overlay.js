import { AlchemyHTMLElement } from "alchemy_admin/components/alchemy_html_element"

class Overlay extends AlchemyHTMLElement {
  static properties = {
    show: { default: false },
    text: { default: "" }
  }

  render() {
    this.id = `overlay`
    this.style.setProperty("display", this.show ? "block" : "none")

    return `
        <alchemy-spinner></alchemy-spinner>
        <div id="overlay_text_box">
            <span id="overlay_text">${this.text}</span>
        </div>
        `
  }
}

customElements.define("alchemy-overlay", Overlay)
