window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# Handles Alchemy hotkeys
#
Alchemy.Hotkeys = (scope) ->
  $search_fields = $('#search_field, #search_input_field', scope)
  $search_fields_clear = $('.search_field_clear, .js_filter_field_clear', scope)

  # Binds keyboard shortcuts to searchfields
  keymage 'alt-f',
    ->
      $search_fields.focus()
      keymage.setScope('search')
    ,
    preventDefault: true
  keymage 'search', 'esc', ->
    $search_fields_clear.click()
    $search_fields.blur()

  # Binds click events to hotkeys
  #
  # Simply add a data-alchemy-hotkey attribute to your link.
  # If a hotkey is triggered by user, the click event of the element gets triggerd.
  #
  $('[data-alchemy-hotkey]', scope).each ->
    $this = $(this)
    keymage $this.data('alchemy-hotkey'), ->
      $this.click()

  keymage 'alt-w', ->
    Alchemy.CurrentWindow.dialog('close')
