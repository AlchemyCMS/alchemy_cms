import { getToken } from "alchemy_admin/utils/ajax"

let initializedSortableElements = false

function onStart(ui) {
  const $sortable = ui.item.closest(".ui-sortable")
  const name = ui.item.data("element-name")
  const $dropzone = $(`[data-droppable-elements~='${name}']`)

  $sortable.sortable("option", "connectWith", $dropzone)
  $sortable.sortable("refresh")
  $dropzone.css("minHeight", 36)
  ui.item.addClass("dragged")

  if (ui.item.hasClass("compact")) {
    ui.placeholder.addClass("compact").css({
      height: ui.item.outerHeight()
    })
  }
}

function onUpdate(event, ui, page_id) {
  // This callback is called twice for both elements, the source and the receiving
  // but, we only want to call ajax callback once on the receiving element.
  if (initializedSortableElements) {
    return
  }

  initializedSortableElements = true

  const $sortable = ui.item.closest(".ui-sortable")
  const element_ids = $.map($sortable.children(), (child) =>
    $(child).attr("data-element-id")
  )
  const parent_element_id = ui.item
    .parent()
    .closest("[data-element-id]")
    .data("element-id")
  const params = {
    page_id,
    authenticity_token: getToken(),
    element_ids
  }

  if (parent_element_id != null) {
    params["parent_element_id"] = parent_element_id
  }
  $(event.target).css("cursor", "progress")
  $.ajax({
    url: Alchemy.routes.order_admin_elements_path,
    type: "POST",
    data: params,
    complete() {
      initializedSortableElements = false
      $(event.target).css("cursor", "")
    }
  })
}

function onStop(ui) {
  const name = ui.item.data("element-name")
  const $dropzone = $(`[data-droppable-elements~='${name}']`)

  $dropzone.css("minHeight", "")
  ui.item.removeClass("dragged")
}

export default function SortableElements(page_id, selector) {
  if (selector == null) {
    selector = "#element_area .sortable-elements"
  }
  const $sortable_area = $(selector)

  const sortable_options = {
    items: "> .element-editor",
    handle: "> .element-header .element-handle",
    placeholder: "droppable_element_placeholder",
    dropOnEmpty: true,
    opacity: 0.5,
    cursor: "move",
    containment: $("#element_area"),
    tolerance: "pointer",
    start: (_evt, ui) => onStart(ui),
    update: (evt, ui) => onUpdate(evt, ui, page_id),
    stop: (_evt, ui) => onStop(ui)
  }

  $sortable_area.sortable(sortable_options)
  $sortable_area.find(".nested-elements").sortable(sortable_options)
}
