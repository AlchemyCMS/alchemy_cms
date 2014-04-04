#= require alchemy/alchemy.tinymce
#= require alchemy/alchemy.link_dialog
#

menubar = document.getElementById('alchemy_menubar')
if menubar
  menubar.style.display = "block"

extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

tinymce.init
  plugins: ['tabfocus']
  skin: 'alchemy'
  selector: '.alchemy-essencetext'
  inline: true
  toolbar: 'undo redo'
  menubar: false

options =
  selector: '.alchemy-essencerichtext'
  inline: true

tinymce.init extend(Alchemy.Tinymce.defaults, options)
