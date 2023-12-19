import Sortable from "sortablejs"
import { post } from "alchemy_admin/utils/ajax"

const SORTABLE_OPTIONS = {
  draggable: ".element-editor",
  handle: ".element-handle",
  ghostClass: "dragged",
  animation: 150,
  swapThreshold: 0.65,
  easing: "cubic-bezier(1, 0, 0, 1)"
}

function onSort(event) {
  const item = event.item
  const parentElement = event.to.parentElement.closest(".element-editor")
  const params = {
    element_id: item.dataset.elementId,
    position: event.newIndex + 1
  }

  if (parentElement) {
    params.parent_element_id = parentElement.dataset.elementId
  }

  post(Alchemy.routes.order_admin_elements_path, params).then((response) => {
    const data = response.data
    Alchemy.growl(data.message)
    Alchemy.PreviewWindow.refresh()
    item.updateTitle(data.preview_text)
  })
}

function createSortable(element) {
  const group = {
    name: element.dataset.elementName,
    put(to, _from, item) {
      return to.el.dataset.droppableElements
        .split(" ")
        .includes(item.dataset.elementName)
    }
  }
  new Sortable(element, {
    ...SORTABLE_OPTIONS,
    onSort,
    group
  })
}

export default function SortableElements(selector) {
  if (selector == null) {
    selector = "#element_area .sortable-elements"
  }
  const sortable_areas = document.querySelectorAll(selector)

  sortable_areas.forEach((element) => {
    createSortable(element)
    element.querySelectorAll(".nested-elements").forEach((nestedElement) => {
      createSortable(nestedElement)
    })
  })
}
