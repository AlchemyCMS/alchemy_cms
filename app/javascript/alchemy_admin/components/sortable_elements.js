import Sortable from "sortablejs"
import { growl } from "alchemy_admin/growler"
import { post } from "alchemy_admin/utils/ajax"
import { reloadPreview } from "alchemy_admin/components/preview_window"

const SORTABLE_OPTIONS = {
  draggable: ".element-editor",
  handle: ".element-handle",
  ghostClass: "dragged",
  animation: 150,
  swapThreshold: 0.65,
  easing: "cubic-bezier(1, 0, 0, 1)"
}

function onStart(event) {
  const name = event.item.dataset.elementName
  document
    .querySelectorAll(`[data-droppable-elements~="${name}"]`)
    .forEach((dropzone) => dropzone.classList.add("droppable-elements"))
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

  // Only send the request if the item was moved to a different container
  // or sorted in the same list. Not on the old list in order to avoid incrementing
  // the position of the other elements.
  if (event.target === event.to) {
    post(Alchemy.routes.order_admin_elements_path, params).then((response) => {
      const data = response.data
      growl(data.message)
      reloadPreview()
      item.updateTitle(data.preview_text)
    })
  }
}

function onEnd() {
  const dropzones = document.querySelectorAll("[data-droppable-elements]")
  dropzones.forEach((dropzone) =>
    dropzone.classList.remove("droppable-elements")
  )
}

class SortableElements extends HTMLElement {
  connectedCallback() {
    const group = {
      name: this.dataset.elementName,
      put(to, _from, item) {
        return to.el.dataset.droppableElements
          .split(" ")
          .includes(item.dataset.elementName)
      }
    }
    new Sortable(this, {
      ...SORTABLE_OPTIONS,
      onStart,
      onSort,
      onEnd,
      group
    })
  }
}

customElements.define("alchemy-sortable-elements", SortableElements)
