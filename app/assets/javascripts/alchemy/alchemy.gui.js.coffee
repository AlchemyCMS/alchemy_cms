window.Alchemy = {} if window.Alchemy == undefined

# Alchemy GUI initializers
Alchemy.GUI =

  # Initializes all Alchemy GUI elements in given scope
  init: (scope) ->
    Alchemy.SelectBox(scope)
    Alchemy.Datepicker(scope)
    Alchemy.Tooltips(scope)
    Alchemy.Buttons.observe(scope)
    # Dialog links use event delegation and therefore do not
    # need to be re-initialized after dom elements get replaced
    unless scope
      Alchemy.watchForDialogs()
    Alchemy.Hotkeys(scope)
    Alchemy.ListFilter(scope)
    Alchemy.Autocomplete.tags(scope)
    $('[data-alchemy-char-counter]', scope).each ->
      new Alchemy.CharCounter(this)

  initElement: ($el) ->
    Alchemy.ElementDirtyObserver($el)
    Alchemy.GUI.init($el)
    Alchemy.ImageLoader($el[0])
    Alchemy.fileEditors($el.find(".essence_file, .essence_video, .essence_audio, .ingredient-editor.file, .ingredient-editor.audio, .ingredient-editor.video").selector)
    Alchemy.pictureEditors($el.find(".essence_picture, .ingredient-editor.picture").selector)
