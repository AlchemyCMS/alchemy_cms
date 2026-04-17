import Sortable from "sortablejs"
import { growl } from "alchemy_admin/growler"
import { post } from "alchemy_admin/utils/ajax"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import { dispatchPageDirtyEvent } from "alchemy_admin/components/element_editor"

const SORTABLE_OPTIONS = {
  draggable: ".sortable-element",
  handle: ".element-handle.draggable",
  ghostClass: "dragged",
  animation: 150,
  swapThreshold: 0.65,
  easing: "cubic-bezier(1, 0, 0, 1)"
}

function onStart(event) {
  const name = event.item.elementName
  document
    .querySelectorAll(`[droppable-elements~="${name}"]`)
    .forEach((dropzone) => dropzone.classList.add("droppable-elements"))
  document
    .querySelectorAll(".add-element-button")
    .forEach((el) => (el.style.visibility = "hidden"))
}

function onSort(event) {
  const item = event.item
  const parentElement = event.to.parentElement.closest(
    "alchemy-sortable-element"
  )
  const params = {
    element_id: item.elementId,
    position: event.newIndex + 1
  }

  if (parentElement) {
    params.parent_element_id = parentElement.elementId
  }

  // Only send the request if the item was moved to a different container
  // or sorted in the same list. Not on the old list in order to avoid incrementing
  // the position of the other elements.
  if (event.target === event.to) {
    post(Alchemy.routes.order_admin_elements_path, params).then((response) => {
      const data = response.data
      growl(data.message)
      if (data.pageHasUnpublishedChanges) {
        dispatchPageDirtyEvent(data)
      }
      reloadPreview()
      item.elementEditor.updateTitle(data.preview_text)
    })
  }
}

function onEnd() {
  const dropzones = document.querySelectorAll("[droppable-elements]")
  dropzones.forEach((dropzone) =>
    dropzone.classList.remove("droppable-elements")
  )
  document
    .querySelectorAll(".add-element-button")
    .forEach((el) => (el.style.visibility = "visible"))
}

class SortableElements extends HTMLElement {
  #sortable = null

  get elementName() {
    return this.getAttribute("element-name")
  }

  get droppableElements() {
    return this.getAttribute("droppable-elements")
  }

  connectedCallback() {
    const group = {
      name: this.elementName,
      put(to, _from, item) {
        return to.el.droppableElements.split(" ").includes(item.elementName)
      }
    }
    this.#sortable = new Sortable(this, {
      ...SORTABLE_OPTIONS,
      onStart,
      onSort,
      onEnd,
      group
    })
  }

  disconnectedCallback() {
    this.#sortable?.destroy()
  }
}

customElements.define("alchemy-sortable-elements", SortableElements)
