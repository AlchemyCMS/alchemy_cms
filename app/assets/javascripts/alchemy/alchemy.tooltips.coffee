window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.Tooltips = (scope) ->
  $('[data-alchemy-tooltip]', scope).each ->
    $el = $(this)
    text = $el.data('alchemy-tooltip')
    $el.wrap('<span class="with-hint"/>')
    $el.after('<span class="hint-bubble">'+text+'</span>')
    return
  return
