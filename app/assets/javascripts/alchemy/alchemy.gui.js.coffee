if typeof window.Alchemy == 'undefined'
  window.Alchemy = {}

Alchemy.GUI =

  initElement: ($el) ->
    Alchemy.ElementDirtyObserver($el)
    Alchemy.SelectBox('select', $el)
    Alchemy.ButtonObserver('button.button', $el)
    Alchemy.Datepicker('input[type="date"]', $el)
    Alchemy.overlayObserver($el)
