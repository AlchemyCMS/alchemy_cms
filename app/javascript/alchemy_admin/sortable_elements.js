export default function SortableElements(page_id, form_token, selector) {
  if (selector == null) {
    selector = "#element_area .sortable-elements"
  }
  let initializedSortableElements = false
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
    update(event, ui) {
      // This callback is called twice for both elements, the source and the receiving
      // but, we only want to call ajax callback once on the receiving element.
      if (initializedSortableElements) {
        return
      }
      const $this = ui.item.parent().closest(".ui-sortable")
      let params = {}
      initializedSortableElements = true
      const element_ids = $.map($this.children(), (child) =>
        $(child).attr("data-element-id")
      )
      const parent_element_id = ui.item
        .parent()
        .closest("[data-element-id]")
        .data("element-id")
      params = {
        page_id,
        authenticity_token: encodeURIComponent(form_token),
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
    },
    start(_evt, ui) {
      const $this = $(this)
      const name = ui.item.data("element-name")
      const $dropzone = $(`[data-droppable-elements~='${name}']`)
      $this.sortable("option", "connectWith", $dropzone)
      $this.sortable("refresh")
      $dropzone.css("minHeight", 36)
      ui.item.addClass("dragged")
      if (ui.item.hasClass("compact")) {
        ui.placeholder.addClass("compact").css({
          height: ui.item.outerHeight()
        })
      }
    },
    stop(_evt, ui) {
      const name = ui.item.data("element-name")
      const $dropzone = $(`[data-droppable-elements~='${name}']`)
      $dropzone.css("minHeight", "")
      ui.item.removeClass("dragged")
    }
  }

  $sortable_area.sortable(sortable_options)
  $sortable_area.find(".nested-elements").sortable(sortable_options)
}
