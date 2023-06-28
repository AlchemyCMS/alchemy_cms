import Sortable from "sortablejs"
import { patch } from "./utils/ajax"

function onFinishDragging(evt) {
  const pageId = evt.item.dataset.pageId
  const url = Alchemy.routes.move_admin_page_path(pageId)
  const data = {
    target_parent_id: evt.to.dataset.parentId,
    new_position: evt.newIndex
  }

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
    })
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
      handle: ".handle",
      onEnd: onFinishDragging
    })
  })
}

export default function () {
  const sortables = document.querySelectorAll("ul.children")
  displayPageFolders()
  createSortables(sortables)
}
