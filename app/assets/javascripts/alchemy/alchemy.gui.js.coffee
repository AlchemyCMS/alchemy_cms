window.Alchemy = {} if window.Alchemy == undefined

# Alchemy GUI initializers
Alchemy.GUI =

  # Initializes all Alchemy GUI elements in given scope
  init: (scope) ->
    Alchemy.SelectBox(scope)
    Alchemy.Datepicker(scope)
    Alchemy.Buttons.observe(scope)
    Alchemy.watchForDialogs(scope)
    Alchemy.Hotkeys(scope)
    Alchemy.ListFilter(scope)
    Alchemy.Spinner.watch(scope)
    Alchemy.Autocomplete.tags(scope)
    $('[data-alchemy-char-counter]', scope).each ->
      new Alchemy.CharCounter(this)

  initElement: ($el) ->
    Alchemy.ElementDirtyObserver($el)
    Alchemy.GUI.init($el)
    Alchemy.ImageLoader($el)
    Alchemy.Spinner.watch($el)
