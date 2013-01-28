window.Alchemy = {} if window.Alchemy == undefined

Alchemy.GUI =

  init: ->
    Alchemy.SelectBox()
    Alchemy.Datepicker()
    Alchemy.Buttons.observe()

  initElement: ($el) ->
    Alchemy.ElementDirtyObserver($el)
    Alchemy.SelectBox($el)
    Alchemy.Buttons.observe($el)
    Alchemy.Datepicker('input[type="date"]', $el)
    Alchemy.overlayObserver($el)
