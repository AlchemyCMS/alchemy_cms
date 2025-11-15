import { patch } from "alchemy_admin/utils/ajax"
import { growl } from "alchemy_admin/growler"
import Spinner from "alchemy_admin/spinner"

/**
 * Custom element for page nodes in the sitemap tree
 * Handles folding/unfolding of page children
 */
export class AlchemyPageNode extends HTMLElement {
  connectedCallback() {
    this.pageId = this.getAttribute("page-id")
    this.folded = this.hasAttribute("folded")

    this.folderButton?.addEventListener("click", this)
  }

  disconnectedCallback() {
    this.folderButton?.removeEventListener("click", this)
  }

  async handleEvent(event) {
    if (event.type === "click") {
      await this.handleFolderClick(event)
    }
  }

  async handleFolderClick(event) {
    event.preventDefault()
    event.stopPropagation()

    const folderButton = event.currentTarget
    folderButton.innerHTML = ""
    const spinner = new Spinner("small")
    spinner.spin(folderButton)

    try {
      await patch(
        Alchemy.routes.fold_admin_page_path(this.pageId),
        null,
        "text/vnd.turbo-stream.html"
      )

      this.folded = !this.folded
      this.toggleAttribute("folded", this.folded)
      this.toggleChildren()
      this.updateFolderIcon()
    } catch (error) {
      growl(error.message || error, "error")
      this.updateFolderIcon()
    } finally {
      spinner.stop()
    }
  }

  toggleChildren() {
    const childrenContainer = this.querySelector(
      `#page_${this.pageId}_children`
    )
    if (childrenContainer) {
      childrenContainer.classList.toggle("hidden", this.folded)
    }
  }

  updateFolderIcon() {
    if (this.folderButton) {
      const iconName = this.folded ? "arrow-right-s" : "arrow-down-s"
      this.folderButton.innerHTML = `<alchemy-icon name="${iconName}"></alchemy-icon>`
    }
  }

  get folderButton() {
    return this.querySelector("button.page_folder")
  }
}

customElements.define("alchemy-page-node", AlchemyPageNode)
