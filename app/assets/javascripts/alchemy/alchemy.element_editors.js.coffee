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
    $elements = $("#element_area .element_editor")
    self = Alchemy.ElementEditors
    self.reinit $elements
    self.currentBindedRTFEditors = []

  # Binds events to all given element editors.
  #
  # Called after replacing element editors via ajax.
  #
  reinit: (elements) ->
    self = Alchemy.ElementEditors
    $elements = $(elements)
    Alchemy.ElementEditors.all = $elements
    self.bindEvents($elements)
    Alchemy.ElementEditors.observeToggler($elements)
    Alchemy.ElementEditors.missingContentsObserver($elements)

  # Click event handler.
  #
  # Also triggers custom 'Alchemy.SelectElement' event on target element in preview frame.
  #
  onClickElement: (e) ->
    self = Alchemy.ElementEditors
    $element = $(this).parents(".element_editor")
    id = $element.attr("id").replace(/\D/g, "")
    e.preventDefault()
    $("#element_area .element_editor").removeClass "selected"
    $element.addClass "selected"
    self.scrollToElement this
    self.selectElementInPreview id
    self.bindUpdate($element)

  # Selects and scrolls to element with given id in the preview window.
  #
  selectElementInPreview: (id) ->
    $frame_elements = document.getElementById("alchemy_preview_window").contentWindow.jQuery("[data-alchemy-element]")
    $selected_element = $frame_elements.closest("[data-alchemy-element='#{id}']")
    $selected_element.trigger "Alchemy.SelectElement"

  bindUpdate: ($element) ->
    self = Alchemy.ElementEditors
    # unbind keyup events of all other elements
    $('.essence_text.content_editor input[type="text"]').off 'keyup'
    # rebind for current element
    $('.essence_text.content_editor input[type="text"]', $element).on 'keyup', (e) ->
      $this = $(this)
      content_id = $this.data('alchemy-content-id')
      content = Alchemy.currentPreviewElement.find("*[data-alchemy-content-id='#{content_id}']")
      content.text($this.val())
      true
    rtf = $('.essence_richtext.content_editor textarea', $element)
    rtf_id = rtf.attr('id')
    rtfUpdateEvent = (e, ed) ->
      textarea = $("##{ed.id}")
      content_id = textarea.data('alchemy-content-id')
      content = Alchemy.currentPreviewElement.find("*[data-alchemy-content-id='#{content_id}']")
      content.html(ed.getContent())
    if rtf_id and rtf_id not in self.currentBindedRTFEditors
      self.currentBindedRTFEditors.push rtf_id
      ed = tinymce.get(rtf_id)
      ed.on 'keyup', (e) -> rtfUpdateEvent(e, ed)
      ed.on 'change', (e) -> rtfUpdateEvent(e, ed)

  # Binds events to element editors
  bindEvents: ->
    self = Alchemy.ElementEditors
    self.all.each ->
      $element = $(this)
      $element.bind "Alchemy.SelectElementEditor", self.selectElement
    self.all.find('.essence_text.content_editor input[type="text"]').focus self.onClickElement
    self.all.find(".element_head").click self.onClickElement
    self.all.find(".element_head").dblclick ->
      id = $(this).parent().attr("id").replace(/\D/g, "")
      self.toggleFold id

  # Selects an element in the element window.
  #
  # Expands the element, if necessary.
  # Also chooses the right cell, if necessary.
  # Can be triggered through custom event 'Alchemy.SelectElementEditor'
  # Used by the elements on click events in the preview frame.
  #
  selectElement: (e) ->
    self = Alchemy.ElementEditors
    id = @id.replace(/\D/g, "")
    $element = $(this)
    $elements = $("#element_area .element_editor")
    $cells = $("#cells .sortable_cell")
    e.preventDefault()
    $elements.removeClass "selected"
    $element.addClass "selected"
    self.bindUpdate($element)
    if $cells.size() > 0
      $cell = $element.parent(".sortable_cell")
      $("#cells").tabs "option", "active", $cells.index($cell)
    if $element.hasClass("folded")
      self.toggleFold id
    else
      self.scrollToElement this

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
          @toggleFold id
      false
    else
      @toggleFold id

  # Folds or expands the element editor with the given id.
  #
  toggleFold: (id) ->
    spinner = Alchemy.Spinner.small()
    element = $('.ajax_folder', "#element_#{id}")
    $("#element_#{id}_folder").hide()
    element.prepend spinner.spin().el
    $.post Alchemy.routes.fold_admin_element_path(id), =>
      $("#element_#{id}_folder").show()
      spinner.stop()
      @scrollToElement "#element_#{id}"

  observeToggler: (scope) ->
    $('[data-element-toggle]', scope).click ->
      Alchemy.ElementEditors.toggle $(this).data('element-toggle')

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
