#= require alchemy/alchemy.tinymce
#= require alchemy/alchemy.link_dialog
#
token = $('meta[name="csrf-token"]').attr('content')
menubar = document.getElementById('alchemy_menubar')

extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

saveContent = (ed) ->
  $el = $(ed.bodyElement)
  id = $el.data('alchemy-content-id')
  $.ajax
    type: 'PATCH'
    url: "/admin/contents/#{id}"
    data:
      content:
        ingredient: ed.getContent()

$.ajaxSetup
  beforeSend: (xhr) ->
    xhr.setRequestHeader('X-CSRF-Token', token)

if menubar
  menubar.style.display = "block"

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

options =
  selector: '.alchemy-essencerichtext'
  inline: true
  save_enablewhendirty: true
  save_onsavecallback: saveContent

tinymce.init extend(Alchemy.Tinymce.defaults, options)
