import { AlchemyHTMLElement } from "./alchemy_html_element"
import { createHtmlElement } from "alchemy_admin/utils/dom_helpers"

class OverlayTabs extends AlchemyHTMLElement {
  connected() {
    const unorderedList = this.getElementsByTagName("ul")[0]
    Array.from(this.getElementsByTagName("alchemy-overlay-tab")).forEach(
      (tab) => {
        unorderedList.append(
          createHtmlElement(`<li><a href="#${tab.id}">${tab.title}</a></li>`)
        )
      }
    )
    $(this).tabs() // call jQuery Tabs - the function can be removed in one of the next migrations
  }

  render() {
    this.id = "overlay_tabs"
    return `
      <ul></ul>
      ${this.initialContent}
    `
  }
}
customElements.define("alchemy-overlay-tabs", OverlayTabs)
