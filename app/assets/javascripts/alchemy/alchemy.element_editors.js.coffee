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
    $elements = $("#element_area .element-editor")
    self = Alchemy.ElementEditors
    self.reinit($elements)

  # Binds events to all given element editors.
  #
  # Called after replacing element editors via ajax.
  #
  reinit: (elements) ->
    self = Alchemy.ElementEditors
    $elements = $(elements)
    $elements.each ->
      self.bindEvent(this)
    $elements.find(".element-header").click (e) =>
      e.stopPropagation()
      @onClickElement(e)
      false
    $elements.find(".element-header").dblclick (e) =>
      id = $(e.target).closest('.element-editor').attr('id').replace(/\D/g, '')
      e.stopPropagation()
      @toggle(id)
      false
    Alchemy.ElementEditors.observeToggler($elements)
    Alchemy.ElementEditors.missingContentsObserver($elements)

  # Click event handler.
  #
  # Also triggers custom 'SelectPreviewElement.Alchemy' event on target element in preview frame.
  #
  onClickElement: (e) ->
    $element = $(e.target).closest(".element-editor")
    element_id = $element.attr("id").replace(/\D/g, "")
    $("#element_area .element-editor").removeClass("selected")
    $element.addClass("selected")
    @selectElement($element)
    @selectElementInPreview(element_id)
    false

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

  # Binds the custom 'FocusElementEditor.Alchemy' event.
  #
  # Triggered, if a user clicks on an element inside the preview iframe.
  #
  bindEvent: (element) ->
    $(element).bind "FocusElementEditor.Alchemy", (e) =>
      $element = $(e.target)
      e.stopPropagation()
      @focusElement($element)
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

  observeToggler: (scope) ->
    $('[data-element-toggle]', scope).click (e) ->
      Alchemy.ElementEditors.toggle $(e.target).data('element-toggle')
      e.stopPropagation()
      e.preventDefault()

  # Handles the missing content links.
  # Ensures that the links query string is converted into post body and send
  # the request via a real ajax post to server, to allow long query strings.
  missingContentsObserver: (scope) ->
    $('[data-create-missing-content]', scope).click ->
      $link = $(this)
      url = this.pathname
      querystring = this.search.replace(/\?/, '')
      $.post url, querystring
      return false
