import Sortable from "sortablejs"
import { patch } from "alchemy_admin/utils/ajax"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"

function onSort(evt) {
  const pageId = evt.item.dataset.pageId
  const url = Alchemy.routes.move_admin_page_path(pageId)
  const data = {
    target_parent_id: evt.to.dataset.parentId,
    new_position: evt.newIndex
  }

  if (evt.target === evt.to) {
    pleaseWaitOverlay(true)
    patch(url, data)
      .then(async (response) => {
        const pageData = await response.data
        const pageEl = document.getElementById(`page_${pageId}`)
        const urlPathEl = pageEl.querySelector(".sitemap_url")

        Alchemy.growl(Alchemy.t("Successfully moved page"))
        urlPathEl.textContent = pageData.url_path
        displayPageFolders()
      })
      .catch((error) => {
        Alchemy.growl(error.message || error, "error")
        Alchemy.currentSitemap.reload()
      })
      .finally(() => {
        pleaseWaitOverlay(false)
      })
  }
}

export function displayPageFolders() {
  document.querySelectorAll("li.sitemap-item").forEach((el) => {
    const pageFolderEl = el.querySelector(".page_folder")
    const list = el.querySelector(".children")
    const page = {
      folded: el.dataset.folded === "true",
      id: el.dataset.pageId,
      type: el.dataset.type
    }

    if (list.children.length > 0 || page.folded) {
      pageFolderEl.outerHTML = HandlebarsTemplates.page_folder({ page })
    } else {
      pageFolderEl.innerHTML = ""
    }
  })
}

export function createSortables(sortables) {
  sortables.forEach((el) => {
    new Sortable(el, {
      group: "pages",
      animation: 150,
      fallbackOnBody: true,
      swapThreshold: 0.65,
      onSort
    })
  })
}

export default function () {
  const sortables = document.querySelectorAll("ul.children")
  displayPageFolders()
  createSortables(sortables)
}
