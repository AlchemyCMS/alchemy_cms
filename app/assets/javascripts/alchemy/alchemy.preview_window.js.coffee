window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.PreviewWindow =

  init: (url) ->
    $iframe = $("<iframe name=\"alchemy_preview_window\" src=\"#{url}\" id=\"alchemy_preview_window\" frameborder=\"0\"/>")
    $reload = $('#reload_preview_button')
    @_showSpinner()
    $iframe.load =>
      @_hideSpinner()
    $('body').append($iframe)
    @currentWindow = $iframe
    @_bindReloadButton()
    @resize()

  resize: ->
    $window = $(window)
    if Alchemy.ElementsWindow.hidden
      width = $window.width() - 64
    else
      width = $window.width() - 466
    height = $window.height() - 73
    width = 240 if width < 240
    @currentWidth = width
    @currentWindow.css
      width: width
      height: height

  refresh: (callback) ->
    $iframe = $('#alchemy_preview_window')
    @_showSpinner()
    $iframe.load (e) =>
      @_hideSpinner()
      if callback
        callback.call(e, $iframe)
    $iframe.attr 'src', $iframe.attr('src')
    true

  _showSpinner: ->
    @reload = $('#reload_preview_button')
    @spinner = Alchemy.Spinner.small()
    @reload.html @spinner.spin().el

  _hideSpinner: ->
    @spinner.stop()
    @reload.html('<span class="icon reload"></span>')

  _bindReloadButton: ->
    $reload = $('#reload_preview_button')
    key 'alt+r', =>
      @refresh()
    $reload.click =>
      @refresh()

Alchemy.reloadPreview = ->
  Alchemy.PreviewWindow.refresh()
