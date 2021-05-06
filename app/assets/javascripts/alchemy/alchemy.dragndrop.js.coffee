#= require jquery-ui/widgets/draggable
#= require jquery-ui/widgets/sortable
#
window.Alchemy = {} if typeof (window.Alchemy) is "undefined"

$.extend Alchemy,

  SortableElements: (page_id, form_token, selector = '#element_area .sortable-elements') ->
    Alchemy.initializedSortableElements = false
    $sortable_area = $(selector)

    getTinymceIDs = (ui) ->
      ids = []
      $textareas = ui.item.find('textarea.has_tinymce')
      $($textareas).each ->
        id = this.id.replace(/tinymce_/, '')
        ids.push parseInt(id, 10)
      return ids

    sortable_options =
      items: "> .element-editor"
      handle: "> .element-header .element-handle"
      placeholder: "droppable_element_placeholder"
      dropOnEmpty: true
      opacity: 0.5
      cursor: "move"
      containment: $('#element_area')
      tolerance: "pointer"
      update: (event, ui) ->
        # This callback is called twice for both elements, the source and the receiving
        # but, we only want to call ajax callback once on the receiving element.
        return if Alchemy.initializedSortableElements
        $this = ui.item.parent().closest('.ui-sortable')
        params = {}
        Alchemy.initializedSortableElements = true
        element_ids = $.map $this.children(), (child) ->
          $(child).attr("data-element-id")
        parent_element_id = ui.item.parent().closest("[data-element-id]").data('element-id')
        params =
          page_id: page_id
          authenticity_token: encodeURIComponent(form_token)
          element_ids: element_ids
        if parent_element_id?
          params['parent_element_id'] = parent_element_id
        $(event.target).css("cursor", "progress")
        $.ajax
          url: Alchemy.routes.order_admin_elements_path
          type: "POST"
          data: params
          complete: ->
            Alchemy.initializedSortableElements = false
            $(event.target).css("cursor", "")
            return
      start: (event, ui) ->
        $this = $(this)
        name = ui.item.data('element-name')
        $dropzone = $("[data-droppable-elements~='#{name}']")
        ids = getTinymceIDs(ui)
        $this.sortable('option', 'connectWith', $dropzone)
        $this.sortable('refresh')
        $dropzone.css('minHeight', 36)
        ui.item.addClass('dragged')
        if ui.item.hasClass('compact')
          ui.placeholder.addClass('compact').css
            height: ui.item.outerHeight()
        Alchemy.Tinymce.remove(ids)
        return
      stop: (event, ui) ->
        ids = getTinymceIDs(ui)
        name = ui.item.data('element-name')
        $dropzone = $("[data-droppable-elements~='#{name}']")
        $dropzone.css('minHeight', '')
        ui.item.removeClass('dragged')
        Alchemy.Tinymce.init(ids)
        return

    $sortable_area.sortable(sortable_options)
    $sortable_area.find('.nested-elements').sortable(sortable_options)
    return
