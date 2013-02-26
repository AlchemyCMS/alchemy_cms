window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# Handlers for element editors.
#
# It provides folding of element editors and
# selecting element editors from the preview frame
# and the elenents window.
#
Alchemy.ElementEditors =

  # Binds all events to element editor partials.
  # Calles once per page load.
  init: ->
    $elements = $("#element_area .element_editor")
    self = Alchemy.ElementEditors
    self.reinit $elements
    return

  # Binds events to all given element editors
  # Called after replacing element editors via ajax.
  reinit: (elements) ->
    self = Alchemy.ElementEditors
    $elements = $(elements)
    $elements.each ->
      self.bindEvent this
      return
    $elements.find(".element_head").click self.onClickElement
    $elements.find(".element_head").dblclick ->
      id = $(this).parent().attr("id").replace(/\D/g, "")
      self.toggleFold id
      return
    return

  # Click event handler.
  # Also triggers custom 'Alchemy.SelectElement' event on target element in preview frame.
  onClickElement: (e) ->
    self = Alchemy.ElementEditors
    $element = $(this).parent(".element_editor")
    id = $element.attr("id").replace(/\D/g, "")
    e.preventDefault()
    $("#element_area .element_editor").removeClass "selected"
    $element.addClass "selected"
    self.scrollToElement this
    $frame_elements = document.getElementById("alchemyPreviewWindow").contentWindow.jQuery("[data-alchemy-element]")
    $selected_element = $frame_elements.closest("[data-alchemy-element=\"" + id + "\"]")
    $selected_element.trigger "Alchemy.SelectElement"
    return

  # Binds the custom 'Alchemy.SelectElementEditor' event.
  # Triggered, if an element gets selected inside the preview iframe.
  bindEvent: (element) ->
    self = Alchemy.ElementEditors
    $(element).bind "Alchemy.SelectElementEditor", self.selectElement
    return

  # Selects an element in the element window.
  # Expands the element, if necessary.
  # Also chooses the right cell, if necessary.
  # Can be triggered through custom event 'Alchemy.SelectElementEditor'
  # Used by the elements on click events in the preview frame.
  selectElement: (e) ->
    self = Alchemy.ElementEditors
    id = @id.replace(/\D/g, "")
    $element = $(this)
    $elements = $("#element_area .element_editor")
    $cells = $("#cells .sortable_cell")
    e.preventDefault()
    $elements.removeClass "selected"
    $element.addClass "selected"
    if $cells.size() > 0
      $cell = $element.parent(".sortable_cell")
      $("#cells").tabs "select", $cell.attr("id")
    if $element.hasClass("folded")
      self.toggleFold id
    else
      self.scrollToElement this
    return

  # Scrolls the element window to given element editor dom element.
  scrollToElement: (el) ->
    $("#alchemyElementWindow").scrollTo el,
      duration: 400
      offset: -10
    return

  # Folds or expands the element editor with the given id.
  toggleFold: (id) ->
    self = Alchemy.ElementEditors
    spinner = Alchemy.Spinner.small()
    element = $('.ajax_folder', '#element_' + id)
    $("#element_" + id + "_folder").hide()
    element.prepend(spinner.spin().el)
    $.post Alchemy.routes.fold_admin_element_path(id), ->
      $("#element_" + id + "_folder").show()
      spinner.stop()
      self.scrollToElement "#element_" + id
      return
    return
