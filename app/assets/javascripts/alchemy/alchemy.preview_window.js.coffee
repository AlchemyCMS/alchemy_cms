window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.PreviewWindow =

  init: (url) ->
    $iframe = $("<iframe name=\"alchemyPreviewWindow\" src=\"#{url}\" id=\"alchemyPreviewWindow\" frameborder=\"0\"/>")
    $iframe.load ->
      $('#reload_preview_button').removeClass('spinning')
    $('body').append($iframe)
    @currentWindow = $iframe
    @_bindReloadButton()
    @resize()

  resize: ->
    $window = $(window)
    width = $window.width() - 464
    height = $window.height() - 86
    width = 240 if width < 240
    @currentWidth = width
    @currentWindow.css
      width: width
      height: height
    return height

  refresh: (callback) ->
    $iframe = $('#alchemyPreviewWindow')
    $reload = $('#reload_preview_button')
    $reload.addClass('spinning')
    $iframe.load (e) ->
      $reload.removeClass('spinning')
      if callback
        callback.call(e, $iframe)
    $iframe.attr 'src', $iframe.attr('src')
    true

  _bindReloadButton: ->
    $reload = $('#reload_preview_button')
    key 'alt+r', =>
      @refresh()
    $reload.click =>
      @refresh()

Alchemy.reloadPreview = ->
  Alchemy.PreviewWindow.refresh()
