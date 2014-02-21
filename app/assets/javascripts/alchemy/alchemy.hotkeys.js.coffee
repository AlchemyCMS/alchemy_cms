window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# Handles Alchemy hotkeys
#
Alchemy.bindedHotkeys = []

Alchemy.Hotkeys = (scope) ->

  # Unbind all previously registered hotkeys.
  unless scope
    $(document).off('keypress')
    for hotkey in Alchemy.bindedHotkeys
      key.unbind(hotkey)

  # Binds keyboard shortcuts to search fields.
  $search_fields = $('#search_field, #search_input_field', scope)
  $search_fields_clear = $('.search_field_clear, .js_filter_field_clear', scope)

  key 'alt+f', ->
    key.setScope('search')
    $search_fields.focus()
    false
  Alchemy.bindedHotkeys.push('alt+f')

  key 'esc', 'search', ->
    $search_fields_clear.click()
    $search_fields.blur()
  Alchemy.bindedHotkeys.push('esc')

  unless scope
    $(document).on 'keypress', (e) ->
      if !$(e.target).is('input, textarea') && String.fromCharCode(e.which) == '?'
        Alchemy.openDialog '/admin/help',
          title: Alchemy._t('help')
          size: '400x492'
        false
      else
        true

  # Binds click events to hotkeys.
  #
  # Simply add a data-alchemy-hotkey attribute to your link.
  # If a hotkey is triggered by user, the click event of the element gets triggerd.
  #
  $('[data-alchemy-hotkey]', scope).each ->
    $this = $(this)
    hotkey = $this.data('alchemy-hotkey')
    key hotkey, -> $this.click()
    Alchemy.bindedHotkeys.push(hotkey)
