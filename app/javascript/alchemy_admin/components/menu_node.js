import { patch } from "alchemy_admin/utils/ajax"
import { growl } from "alchemy_admin/growler"

/**
 * Custom element for menu nodes in the nodes tree
 * Handles folding and unfolding of its children
 */
export class AlchemyMenuNode extends HTMLElement {
  connectedCallback() {
    this.addEventListener("click", this)
  }

  disconnectedCallback() {
    this.removeEventListener("click", this)
  }

  handleEvent(event) {
    // Clicks of nested menu nodes bubble up here as well
    if (event.target.closest("alchemy-node-folder") === this.folder) {
      this.toggleFolded(event)
    }
  }

  async toggleFolded(event) {
    event.preventDefault()

    try {
      await patch(Alchemy.routes.node.toggle_folded_api_path(this.nodeId))
      this.folded = !this.folded
    } catch (error) {
      growl(error.message || error, "error")
    }
  }

  /**
   * Shows the fold toggle only for nodes that have something to fold
   */
  updateFolder() {
    this.folder.hidden = !(this.hasChildren || this.folded)
  }

  get folded() {
    return this.hasAttribute("folded")
  }

  set folded(value) {
    this.toggleAttribute("folded", value)
    this.folder.toggleAttribute("folded", value)
    this.childrenList.classList.toggle("folded", value)
  }

  get hasChildren() {
    return (
      this.childrenList.querySelectorAll(":scope > alchemy-menu-node").length >
      0
    )
  }

  get nodeId() {
    return this.getAttribute("node-id")
  }

  get folder() {
    return this.querySelector(":scope > li > .sitemap_node alchemy-node-folder")
  }

  get childrenList() {
    return this.querySelector(":scope > li > ul.children")
  }
}

customElements.define("alchemy-menu-node", AlchemyMenuNode)
