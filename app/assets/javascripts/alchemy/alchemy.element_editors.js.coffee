window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# Handlers for element editors.
#
# It provides folding of element editors and
# selecting element editors from the preview frame
# and the elenents window.
#
Alchemy.ElementEditors =

  # Binds all events to element editor partials.
  #
  # Calles once per page load.
  #
  init: ->
    @element_area = $("#element_area")
    # Binds the custom FocusElementEditor event
    @element_area.on "FocusElementEditor.Alchemy", '.element-editor', (e) =>
      @onFocusElement(e)
    @bindClickEvents()
    return

  # Binds click events on several DOM elements from element editors
  # Uses event delegation, so it is not necessary to rebind these events.
  bindClickEvents: ->
    @element_area.on "click", ".element-header", (e) =>
      @onClickElement(e)
    @element_area.on "dblclick", ".element-header", (e) =>
      @onDoubleClickElement(e)
    @element_area.on "click", "[data-element-toggle]", (e) =>
      @onClickToggle(e)
    @element_area.on "click", '[data-create-missing-content]', (e) =>
      @onClickMissingContent(e)
    return

  # Selects and scrolls to element with given id in the preview window.
  #
  selectElementInPreview: (element_id) ->
    $frame_elements = document
                        .getElementById("alchemy_preview_window")
                        .contentWindow
                        .jQuery("[data-alchemy-element]")
    $selected_element = $frame_elements.closest("[data-alchemy-element='#{element_id}']")
    $selected_element.trigger("SelectPreviewElement.Alchemy")
    return

  # Selects element
  # Scrolls to element
  # Unfold if folded
  # Also chooses the right cell, if necessary.
  # Can be triggered through custom event 'FocusElementEditor.Alchemy'
  # Used by the elements on click events in the preview frame.
  focusElement: ($element) ->
    element_id = $element.attr('id').replace(/\D/g, "")
    @selectCellForElement($element)
    # If we have folded parents we need to unfold each of them
    # and then finally scroll to or unfold ourself
    $folded_parents = $element.parents('.element-editor.folded')
    @selectElement($element)
    if $folded_parents.length > 0
      @unfoldParents $folded_parents, =>
        @scrollToOrUnfold(element_id)
        return
    else
      @scrollToOrUnfold(element_id)
    return

  # Select cell for given element
  selectCellForElement: ($element) ->
    $cells = $("#cells .sortable_cell")
    if $cells.size() > 0
      $cell = $element.parent(".sortable_cell")
      $("#cells").tabs("option", "active", $cells.index($cell))

  # Marks an element as selected in the element window and scrolls to it.
  #
  selectElement: ($element) ->
    $elements = $("#element_area .element-editor")
    $elements.removeClass("selected")
    $element.addClass("selected")
    @scrollToElement($element)
    return

  # Unfolds given parents until the last one is reached, then calls callback
  unfoldParents: ($folded_parents, callback) ->
    last_parent = $folded_parents[$folded_parents.length - 1]
    $folded_parents.each (_index, parent_element) =>
      parent_id = parent_element.id.replace(/\D/g, "")
      if last_parent == parent_element
        @scrollToOrUnfold(parent_id, callback)
      else
        @scrollToOrUnfold(parent_id)
      return
    return

  # Scrolls to element with given id
  #
  # If it's folded it unfolds it.
  #
  # Also takes an optional callback that gets triggered after element is unfolded.
  #
  scrollToOrUnfold: (element_id, callback) ->
    $el = $("#element_#{element_id}")
    @selectElement($el)
    if $el.hasClass("folded")
      @toggleFold(element_id, callback)
    return

  # Scrolls the element window to given element editor dom element.
  #
  scrollToElement: (el) ->
    $("#element_area").scrollTo el,
      duration: 400
      offset: -10

  # Expands or folds a element editor
  #
  # If the element is dirty (has unsaved changes) it displays a warning.
  #
  toggle: (id, text) ->
    el = $("#element_#{id}")
    if Alchemy.isElementDirty(el)
      Alchemy.openConfirmDialog Alchemy._t('element_dirty_notice'),
        title: Alchemy._t('warning')
        ok_label: Alchemy._t('ok')
        cancel_label: Alchemy._t('cancel')
        on_ok: =>
          @toggleFold(id)
      false
    else
      @toggleFold(id)

  # Folds or expands the element editor with the given id.
  #
  toggleFold: (id, callback) ->
    $el = $("#element_#{id}")
    spinner = Alchemy.Spinner.small()
    $toggler = $('> .element-header .ajax-folder', $el)
    $("#element_#{id}_folder").hide()
    $toggler.prepend(spinner.spin().el)
    $.post Alchemy.routes.fold_admin_element_path(id), =>
      $("#element_#{id}_folder").show()
      spinner.stop()
      if callback?
        callback.call()
      return

  # Event handlers

  # Click event handler for element head.
  #
  # - Focuses the element
  # - Triggers custom 'SelectPreviewElement.Alchemy' event on target element in preview frame.
  #
  onClickElement: (e) ->
    $element = $(e.target).closest(".element-editor")
    element_id = $element.attr("id").replace(/\D/g, "")
    $("#element_area .element-editor").removeClass("selected")
    $element.addClass("selected")
    @selectElement($element)
    @selectElementInPreview(element_id)
    e.preventDefault()
    e.stopPropagation()
    false

  # Double click event handler for element head.
  onDoubleClickElement: (e) ->
    id = $(e.target).closest('.element-editor').attr('id').replace(/\D/g, '')
    @toggle(id)
    e.preventDefault()
    e.stopPropagation()
    false

  # Click event handler for element toggle icon.
  onClickToggle: (e) ->
    id = $(e.target).data('element-toggle')
    @toggle(id)
    e.preventDefault()
    e.stopPropagation()
    false

  # Handles the custom 'FocusElementEditor.Alchemy' event.
  #
  # Triggered, if a user clicks on an element inside the preview iframe.
  #
  onFocusElement: (e) ->
    $element = $(e.target)
    @focusElement($element)
    e.stopPropagation()
    false

  # Handles the missing content button click events.
  #
  # Ensures that the links query string is converted into post body and send
  # the request via a real ajax post to server, to allow long query strings.
  #
  onClickMissingContent: (e) ->
    link = e.target
    url = link.pathname
    querystring = link.search.replace(/\?/, '')
    $.post(url, querystring)
    false
