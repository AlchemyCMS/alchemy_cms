import Sortable from "sortablejs"
import ajax from "./utils/ajax"
import { updateFolderLinks, handleFolderLinks } from "./folder_links"

const pageSelector = "li.page"

function initSortable(el) {
  new Sortable(el, {
    group: "pages",
    animation: 150,
    fallbackOnBody: true,
    swapThreshold: 0.65,
    handle: ".sitemap_sitename",
    invertSwap: true,
    onEnd: onFinishDragging
  })
}

function afterFold(responseData, list) {
  const page = responseData.pages[0]
  if (page.children.length > 0) {
    const template_markup = document
      .getElementById("sitemap-list")
      .innerHTML.replace(/\/\d+/, "/{{id}}")
    const treeTemplate = Handlebars.compile(template_markup)
    const children = document
      .createRange()
      .createContextualFragment(treeTemplate({ children: page.children }))
    list.appendChild(children)
  } else {
    list.innerHTML = ""
  }
  list.parentNode.querySelectorAll(".children").forEach((el) => {
    initSortable(el)
  })
}

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
      updateFolderLinks(pageSelector)
    })
    .catch((error) => {
      console.error(error)
      Alchemy.growl(error.error || error, "error")
    })
}

export default function PageSorter() {
  handleFolderLinks(
    "#sitemap",
    {
      parent_selector: pageSelector,
      url: Alchemy.routes.fold_api_page_path
    },
    afterFold
  )
  updateFolderLinks(pageSelector)

  document.querySelectorAll("#sitemap ul").forEach((el) => {
    initSortable(el)
  })
}
