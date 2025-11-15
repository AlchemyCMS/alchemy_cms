import Sortable from "sortablejs"
import { growl } from "alchemy_admin/growler"
import { patch } from "alchemy_admin/utils/ajax"
import { translate } from "alchemy_admin/i18n"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"

/**
 * Custom element for the sitemap container
 * Handles search/filter functionality and drag-and-drop sorting
 */
export class AlchemySitemap extends HTMLElement {
  connectedCallback() {
    this.searchInput = document.querySelector(".search_input_field")
    this.clearButton = document.querySelector("#search_field_clear")
    this.resultCounter = document.querySelector("#page_filter_result")

    this.setupSearch()

    // Wait for child custom elements to be defined before setting up sortables
    requestAnimationFrame(() => {
      this.setupSortables()
    })

    // Set up MutationObserver to re-initialize sortables when children containers are added
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        mutation.addedNodes.forEach((node) => {
          if (node.nodeType !== Node.ELEMENT_NODE) return

          // If the added node itself is a children container, initialize it
          if (node.classList?.contains("children")) {
            this.setupSortable(node)
          }

          // Also check for children containers nested within the added node
          // This handles cases where a parent element with nested children is added at once
          node
            .querySelectorAll(".children")
            .forEach((el) => this.setupSortable(el))
        })
      })
    })

    // Observe the sitemap for added nodes
    this.observer.observe(this, {
      childList: true,
      subtree: true
    })
  }

  disconnectedCallback() {
    this.teardownSearch()
    this.observer?.disconnect()
  }

  setupSearch() {
    this.searchInput?.addEventListener("input", this)
    this.clearButton?.addEventListener("click", this)
  }

  teardownSearch() {
    this.searchInput?.removeEventListener("input", this)
    this.clearButton?.removeEventListener("click", this)
  }

  handleEvent(event) {
    if (event.type === "input" && event.target === this.searchInput) {
      this.handleSearch(event)
    } else if (event.type === "click" && event.target === this.clearButton) {
      this.handleClearSearch(event)
    }
  }

  handleSearch(event) {
    const term = event.target.value.toLowerCase().trim()

    if (term === "") {
      this.clearFilter()
      return
    }

    this.filterPages(term)
  }

  filterPages(term) {
    const allPages = this.querySelectorAll(".sitemap_page")
    let matchCount = 0
    let firstMatch = null

    allPages.forEach((pageElement) => {
      const pageName = pageElement.getAttribute("name") || ""

      if (pageName.toLowerCase().includes(term)) {
        pageElement.classList.add("highlight")
        pageElement.classList.remove("no-match")
        matchCount++
        if (!firstMatch) firstMatch = pageElement
      } else {
        pageElement.classList.remove("highlight")
        pageElement.classList.add("no-match")
      }
    })

    // Update result counter

    if (matchCount === 1) {
      this.resultCounter.textContent = `1 ${translate("page_found")}`
      this.resultCounter.style.display = "block"
    } else if (matchCount > 1) {
      this.resultCounter.textContent = `${matchCount} ${translate("pages_found")}`
      this.resultCounter.style.display = "block"
    } else {
      this.resultCounter.style.display = "none"
    }

    // Scroll first match into view
    if (firstMatch) {
      firstMatch.scrollIntoView({ behavior: "smooth", block: "center" })
    }
  }

  clearFilter() {
    const allPages = this.querySelectorAll(".sitemap_page")
    allPages.forEach((pageElement) => {
      pageElement.classList.remove("highlight", "no-match")
    })

    this.resultCounter.style.display = "none"
  }

  handleClearSearch(event) {
    event.preventDefault()
    this.searchInput.value = ""
    this.clearFilter()
  }

  setupSortable(container) {
    new Sortable(container, {
      group: "pages",
      animation: 150,
      fallbackOnBody: true,
      swapThreshold: 0.65,
      handle: ".page-icon.handle",
      draggable: "alchemy-page-node",
      onEnd: (evt) => this.handleSort(evt)
    })
  }

  setupSortables() {
    const sortables = this.querySelectorAll(".children")
    sortables.forEach((el) => this.setupSortable(el))
  }

  async handleSort(evt) {
    // Only proceed if actually moved to different position/container
    if (evt.from === evt.to && evt.oldIndex === evt.newIndex) {
      return
    }

    // evt.item is the <alchemy-page-node> element being dragged
    const pageNode = evt.item
    const pageId = pageNode.pageId
    const url = Alchemy.routes.move_admin_page_path(pageId)
    const data = {
      target_parent_id: evt.to.dataset.parentId,
      new_position: evt.newIndex
    }

    pleaseWaitOverlay(true)

    try {
      const response = await patch(url, data)
      const pageData = await response.data

      // Update the URL path of the moved page
      const pageEl = pageNode.querySelector(`#page_${pageId}`)
      if (pageEl) {
        const urlPathEl = pageEl.querySelector(".sitemap_url")
        if (urlPathEl && pageData.url_path) {
          urlPathEl.textContent = pageData.url_path
        }
      }

      // Update folder icons for affected parent pages
      this.updateFolderIcons(evt.from, evt.to)

      growl(translate("Successfully moved page"))
    } catch (error) {
      growl(error.message || error, "error")
      // Revert the DOM change by reloading on error
      window.location.reload()
    } finally {
      pleaseWaitOverlay(false)
    }
  }

  updateFolderIcons(fromContainer, toContainer) {
    // Update folder icon for source parent (might now have no children)
    this.updateParentFolderIcon(fromContainer)

    // Update folder icon for destination parent (now definitely has children)
    if (fromContainer !== toContainer) {
      this.updateParentFolderIcon(toContainer)
    }
  }

  updateParentFolderIcon(childrenContainer) {
    // Find the parent page node
    const parentPageNode = childrenContainer.closest("alchemy-page-node")
    if (!parentPageNode) return

    const folderButton = parentPageNode.querySelector(".page_folder")
    if (!folderButton) return

    const hasChildren =
      childrenContainer.querySelectorAll(":scope > alchemy-page-node").length >
      0
    const isFolded = parentPageNode.folded

    // If has children or is folded, show the folder icon
    if (hasChildren || isFolded) {
      if (folderButton.tagName === "SPAN") {
        // Convert span to button with icon
        const iconName = isFolded ? "arrow-right-s" : "arrow-down-s"
        folderButton.outerHTML = `<button class="page_folder icon_button">
          <alchemy-icon name="${iconName}"></alchemy-icon>
        </button>`

        // Re-setup event listener for the new element
        const newFolderButton = parentPageNode.querySelector(".page_folder")
        newFolderButton.addEventListener("click", parentPageNode)
      }
    } else {
      // No children and not folded, convert to empty span
      if (folderButton.tagName === "BUTTON") {
        folderButton.outerHTML = '<span class="page_folder"></span>'
      }
    }
  }
}

customElements.define("alchemy-sitemap", AlchemySitemap)
