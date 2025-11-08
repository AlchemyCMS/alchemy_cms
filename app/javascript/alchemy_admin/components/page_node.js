import { patch } from "alchemy_admin/utils/ajax"
import { growl } from "alchemy_admin/growler"
import Spinner from "alchemy_admin/spinner"

/**
 * Custom element for page nodes in the sitemap tree
 * Handles folding/unfolding of page children
 */
export class AlchemyPageNode extends HTMLElement {
  connectedCallback() {
    this.pageId = this.dataset.pageId
    this.folded = this.dataset.folded === "true"

    this.setupFoldingBehavior()
  }

  disconnectedCallback() {
    this.removeFoldingBehavior()
  }

  setupFoldingBehavior() {
    const folderIcon = this.querySelector(".page_folder")
    if (!folderIcon) return

    folderIcon.addEventListener("click", this)
  }

  removeFoldingBehavior() {
    const folderIcon = this.querySelector(".page_folder")
    if (folderIcon) {
      folderIcon.removeEventListener("click", this)
    }
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
      this.dataset.folded = String(this.folded)
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
    const folderButton = this.querySelector(".page_folder")
    if (folderButton && folderButton.tagName === "A") {
      const iconName = this.folded ? "arrow-right-s" : "arrow-down-s"
      folderButton.innerHTML = `<alchemy-icon name="${iconName}"></alchemy-icon>`
    }
  }
}

customElements.define("alchemy-page-node", AlchemyPageNode)
