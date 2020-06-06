import Sortable from "sortablejs"
import ajax from "./utils/ajax"

function onFinishDragging(evt) {
  const url = Alchemy.routes.move_api_page_path(evt.item.dataset.id)
  const data = {
    target_parent_id: evt.to.dataset.pageId,
    new_position: evt.newIndex
  }

  ajax("PATCH", url, data)
    .then((response) => {
      const data = response.data
      const message = Alchemy.t("Successfully moved page")
      const url_path = evt.item.querySelector(".sitemap_url a")
      url_path.setAttribute("href", data.url_path)
      url_path.innerHTML = data.url_path
      Alchemy.growl(message)
    })
    .catch((error) => {
      console.error(error)
      Alchemy.growl(error.error || error, "error")
    })
}

export default function PageSorter() {
  document.querySelectorAll("#sitemap ul").forEach((el) => {
    new Sortable(el, {
      group: "pages",
      animation: 150,
      fallbackOnBody: true,
      swapThreshold: 0.65,
      handle: ".sitemap_left_images",
      invertSwap: true,
      onEnd: onFinishDragging
    })
  })
}
