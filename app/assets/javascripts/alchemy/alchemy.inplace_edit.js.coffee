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

if typeof(jQuery) is 'undefined'
  Alchemy.loadjQuery(onload)
else
  onload(jQuery)
