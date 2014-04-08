#= require alchemy/alchemy.jquery_loader
#= require alchemy/alchemy.tinymce
#= require alchemy/alchemy.link_dialog

# Loaded when jQuery is loaded
onload = ($) ->
  # Save content action
  saveContent = (ed) ->
    $el = $(ed.bodyElement)
    id = $el.data('alchemy-content-id')
    $.ajax
      type: 'PATCH'
      url: "/admin/contents/#{id}"
      data:
        content:
          ingredient: ed.getContent()

  # Set csrf token for ajax post requests
  token = $('meta[name="csrf-token"]').attr('content')
  $.ajaxSetup
    beforeSend: (xhr) ->
      xhr.setRequestHeader('X-CSRF-Token', token)

  # Init EssenceTexts
  tinymce.init
    plugins: ['tabfocus save']
    skin: 'alchemy'
    selector: '.alchemy-essencetext'
    inline: true
    toolbar: 'save | undo redo'
    menubar: false
    entity_encoding: 'raw'
    save_enablewhendirty: true
    save_onsavecallback: saveContent

  # Init EssenceRichtexts
  tinymce.init $.extend({}, Alchemy.Tinymce.defaults, {
    selector: '.alchemy-essencerichtext',
    inline: true,
    save_enablewhendirty: true,
    save_onsavecallback: saveContent
  })

  # Binding events to editor instances
  tinymce.on 'AddEditor', (e) ->
    ed = e.editor
    $el = $(ed.getElement())
    # Store the element editor instance on this node
    storeElementEditor($el, ed)
    # Focus the element editor field in elements window
    ed.on 'focus', (e) ->
      $element = $el.data('alchemy-element-editor').parents('element_editor')
      $element.trigger("Alchemy.SelectElementEditor")
    # If the editor has unsaved changes
    # ed.on 'blur', (e) ->
    #   console.log('Yo, unsaved changes in here!') if ed.isDirty()
    # If the editor's content changed
    ed.on 'change', (e) -> editorUpdateEvent($el, ed)
    ed.on 'keyup',  (e) -> editorUpdateEvent($el, ed)
    ed.on 'undo',   (e) -> editorUpdateEvent($el, ed)

  # Updates the content in element editor fields of element window
  editorUpdateEvent = ($el, ed) ->
    $el_editor = $el.data('alchemy-element-editor')
    if $el_editor.is('textarea')
      el_editor_tinymce = $el.data('alchemy-element-tinymce-editor')
      el_editor_tinymce.setContent ed.getContent()
    else if $el_editor.is('input')
      $el_editor.val ed.getContent()
    true

  # Returns the element editor field from element window
  getElementEditor = (id) ->
    window.parent.$("[data-alchemy-content-id='#{id}']")

  # Stores the element editor field from element window
  # Also stores tinymce instance for EssenceRichtexts
  storeElementEditor = ($el, ed) ->
    id = $el.data('alchemy-content-id')
    $element_editor = getElementEditor(id)
    $el.data 'alchemy-element-editor', $element_editor
    # Store the tinymce instance for EssenceRichtexts
    if $el.hasClass('alchemy-essencerichtext')
      element_editor_ed = window.parent.tinymce.get $element_editor.attr('id')
      $el.data 'alchemy-element-tinymce-editor', element_editor_ed
    true

# Layze load jQuery if not defined
if typeof(jQuery) is 'undefined'
  Alchemy.loadjQuery(onload)
else
  onload(jQuery)
