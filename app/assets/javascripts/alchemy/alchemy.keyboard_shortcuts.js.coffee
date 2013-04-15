window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# Keyboard shortcuts
#
Alchemy.KeyboardShortcuts = ->

  $search_fields = $('#search_field, #search_input_field')

  # Binds keyboard shortcuts to searchfields
  keymage 'alt-f',
    ->
      $search_fields.focus()
      keymage.setScope('search')
    ,
    preventDefault: true
  keymage 'search', 'esc', ->
    $search_fields.val('')
    $search_fields.blur()

  # Shortcuts for creating new resources
  keymage 'alt-n', ->
    $('#create_resource_button').click()
