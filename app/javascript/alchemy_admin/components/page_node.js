import { patch } from "alchemy_admin/utils/ajax"
import { growl } from "alchemy_admin/growler"
import Spinner from "alchemy_admin/spinner"

const BUTTON = "BUTTON"
const SPAN = "SPAN"

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

  /**
   * Updates the folder button state based on whether the node has children
   * Converts between button and span as needed
   */
  updateFolderButton() {
    const folderElement = this.querySelector(".page_folder")
    if (!folderElement) return

    const shouldShowButton = this.hasChildren || this.folded

    if (shouldShowButton && folderElement.tagName === SPAN) {
      // Convert span to button with icon
      const iconName = this.folded ? "arrow-right-s" : "arrow-down-s"
      folderElement.outerHTML = `<button class="page_folder icon_button">
        <alchemy-icon name="${iconName}"></alchemy-icon>
      </button>`

      // Re-attach event listener to the new button element
      this.folderButton?.addEventListener("click", this)
    } else if (!shouldShowButton && folderElement.tagName === BUTTON) {
      // Convert button to empty span (no children and not folded)
      folderElement.outerHTML = '<span class="page_folder"></span>'
    } else if (shouldShowButton && folderElement.tagName === BUTTON) {
      // Button exists, just update the icon direction
      this.updateFolderIcon()
    }
  }

  get hasChildren() {
    const childrenContainer = this.querySelector(
      `#page_${this.pageId}_children`
    )
    if (!childrenContainer) return false

    return (
      childrenContainer.querySelectorAll(":scope > alchemy-page-node").length >
      0
    )
  }

  get folderButton() {
    return this.querySelector("button.page_folder")
  }
}

customElements.define("alchemy-page-node", AlchemyPageNode)
