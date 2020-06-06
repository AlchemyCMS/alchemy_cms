import ajax from "./utils/ajax"
import { on } from "./utils/events"

export function updateFolderLinks(selector) {
  document.querySelectorAll(selector).forEach((el) => {
    const leftIconArea = el.querySelector(".sitemap_left_images")
    const list = el.querySelector(".children")
    const item = { folded: el.dataset.folded === "true", id: el.dataset.id }

    if (list.children.length > 0 || item.folded) {
      leftIconArea.innerHTML = HandlebarsTemplates.folder_link({ item })
    } else {
      leftIconArea.innerHTML = "&nbsp;"
    }
  })
}

export function handleFolderLinks(selector, options = {}, callback) {
  on("click", selector, ".folder_link", function () {
    const itemId = this.dataset.itemId
    const parent = this.closest(options.parent_selector)
    const list = parent.querySelector(".children")

    return ajax("PATCH", options.url(itemId))
      .then((response) => {
        list.classList.toggle("folded")
        parent.dataset.folded =
          parent.dataset.folded == "true" ? "false" : "true"
        if (callback) callback(response.data, list)
        updateFolderLinks(options.parent_selector)
      })
      .catch((error) => {
        console.error(error)
        Alchemy.growl(error.error || error, "error")
      })
  })
}
