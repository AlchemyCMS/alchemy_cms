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
    @bindEvents()
    return

  # Binds click events on several DOM elements from element editors
  # Uses event delegation, so it is not necessary to rebind these events.
  bindEvents: ->
    $('body').on 'click', (e) =>
      @onClickBody(e)
    @element_area.on "click", ".element-editor", (e) =>
      @onClickElement(e)
    @element_area.on "dblclick", ".element-header", (e) =>
      @onDoubleClickElement(e)
    @element_area.on "click", "[data-element-toggle]", (e) =>
      @onClickToggle(e)
    @element_area.on "click", '[data-create-missing-content]', (e) =>
      @onClickMissingContent(e)
    # Binds the custom FocusElementEditor event
    @element_area.on "FocusElementEditor.Alchemy", '.element-editor', (e) =>
      @onFocusElement(e)
    # Binds the custom SaveElement event
    @element_area.on "SaveElement.Alchemy", '.element-editor', (e, data) =>
      @onSaveElement(e, data)
    # Listen to postMessage messages from the preview frame
    window.addEventListener 'message', (e) =>
      @onMessage(e.data)
      true
    return

  # Selects and scrolls to element with given id in the preview window.
  #
  focusElementPreview: (element_id) ->
    Alchemy.PreviewWindow.postMessage
      message: 'Alchemy.focusElement'
      element_id: element_id
    return

  # Selects element
  # Scrolls to element
  # Unfold if folded
  # Also chooses the right fixed elements tab, if necessary.
  # Can be triggered through custom event 'FocusElementEditor.Alchemy'
  # Used by the elements on click events in the preview frame.
  focusElement: ($element) ->
    element_id = $element.attr('id').replace(/\D/g, "")
    Alchemy.ElementsWindow.show()
    @selectTabForElement($element)
    # If we have folded parents we need to unfold each of them
    # and then finally scroll to or unfold ourself
    $folded_parents = $element.parents('.element-editor.folded')
    if $folded_parents.length > 0
      @unfoldParents $folded_parents, =>
        @scrollToOrUnfold(element_id)
        return
    else
      @scrollToOrUnfold(element_id)
    return

  # Selects tab for given element
  selectTabForElement: ($element) ->
    $tabs = $("#fixed-elements .sortable-elements")
    if $tabs.size() > 0
      $tab = $element.closest(".sortable-elements")
      $("#fixed-elements").tabs("option", "active", $tabs.index($tab))

  # Marks an element as selected in the element window and scrolls to it.
  #
  selectElement: ($element, scroll = false) ->
    $("#element_area .element-editor").not($element[0]).removeClass("selected")
    $element.addClass("selected")
    @scrollToElement($element) if scroll
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
    if $el.hasClass("folded")
      @toggleFold(element_id, callback)
    else
      @selectElement($el, true)
    return

  # Scrolls the element window to given element editor dom element.
  #
  scrollToElement: (el) ->
    $("#element_area").scrollTo el,
      axis: 'y',
      duration: 400
      offset: -6

  # Expands or folds a element editor
  #
  # If the element is dirty (has unsaved changes) it displays a warning.
  #
  toggle: (id, text) ->
    el = $("#element_#{id}")
    if Alchemy.isElementDirty(el)
      Alchemy.openConfirmDialog Alchemy.t('element_dirty_notice'),
        title: Alchemy.t('warning')
        ok_label: Alchemy.t('ok')
        cancel_label: Alchemy.t('cancel')
        on_ok: =>
          @toggleFold(id)
      false
    else
      @toggleFold(id)

  # Folds or expands the element editor with the given id.
  #
  toggleFold: (id, callback) ->
    spinner = new Alchemy.Spinner('small')
    spinner.spin("#element_#{id} > .element-header .ajax-folder")
    $("#element_#{id}_folder .icon").hide()
    $.post Alchemy.routes.fold_admin_element_path(id), =>
      callback.call() if callback?
      return

  # Updates the title quote if one of the several conditions are met
  updateTitle: (element, title, event) ->
    return true if not @_shouldUpdateTitle(element, event)
    @setTitle(element, title)
    return

  # Sets the title quote without checking that the conditions are met
  setTitle: (element, title) ->
    $quote = element.find('> .element-header .preview_text_quote')
    $quote.text(title)
    return

  # Sets the element to saved state
  onSaveElement: (event, data) ->
    $element = $(event.currentTarget)
    # JS event bubbling will also update the parents element quote.
    @updateTitle($element, data.previewText, event)
    # Prevent this event from beeing called twice on the same element
    if event.currentTarget == event.target
      Alchemy.setElementClean($element)
      Alchemy.Buttons.enable($element)
    true

  # Event handlers

  onMessage: (data) ->
    if data.message == 'Alchemy.focusElementEditor'
      $element = $("#element_#{data.element_id}")
      Alchemy.ElementEditors.focusElement($element)

  onClickBody: (e) ->
    element = $(e.target).parents('.element-editor')[0]
    $('#element_area .element-editor').not(element).removeClass('selected')
    unless element
      Alchemy.PreviewWindow.postMessage(message: 'Alchemy.blurElements')
    return

  # Click event handler for element body.
  #
  # - Focuses the element
  # - Sends 'Alchemy.focusElement' message to preview frame.
  #
  onClickElement: (e) ->
    $target = $(e.target)
    $element = $target.closest(".element-editor")
    element_id = $element.attr("id").replace(/\D/g, "")
    @selectElement($element)
    @focusElementPreview(element_id)
    return

  # Double click event handler for element head.
  onDoubleClickElement: (e) ->
    id = $(e.target).closest('.element-editor').attr('id').replace(/\D/g, '')
    @toggle(id)
    e.preventDefault()
    return

  # Click event handler for element toggle icon.
  onClickToggle: (e) ->
    id = $(e.currentTarget).data('element-toggle')
    @toggle(id)
    e.preventDefault()
    e.stopPropagation()
    return

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

  # private

  _shouldUpdateTitle: (element, event) ->
    editors = element.find('> .element-content .element-content-editors, > .element-content .element-ingredient-editors').children()
    if @_hasParents(element)
      editors.length != 0
    else if @_isParent(element) && @_isFirstChild $(event.target)
      editors.length == 0
    else
      not @_isParent(element)

  _hasParents: (element) ->
    element.parents('.element-editor').length != 0

  _isParent: (element) ->
    element.find('.nestable-elements').length != 0

  _isFirstChild: (element) ->
    element.closest('.nestable-elements').find(':first-child').is(element)
