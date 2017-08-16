window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.PreviewWindow =
  MIN_WIDTH: 240
  HEIGHT: 75 # Top menu height

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
    width = @_calculateWidth()
    height = $(window).height() - @HEIGHT
    width = @MIN_WIDTH if width < @MIN_WIDTH
    @currentWidth = width
    @currentWindow.css
      width: width
      height: height

  refresh: (callback) ->
    $iframe = $('#alchemy_preview_window')
    @_showSpinner()
    # We need to be sure that no load event is binded on the preview frame.
    $iframe.off('load')
    $iframe.load (e) =>
      @_hideSpinner()
      if callback
        callback.call(e, $iframe)
    $iframe.attr 'src', $iframe.attr('src')
    true

  _showSpinner: ->
    @reload = $('#reload_preview_button')
    @spinner = new Alchemy.Spinner('small')
    @reload.html @spinner.spin().el

  _hideSpinner: ->
    @spinner.stop()
    @reload.html('<span class="icon-refresh"></span>')

  _bindReloadButton: ->
    $reload = $('#reload_preview_button')
    key 'alt+r', =>
      @refresh()
    $reload.click =>
      @refresh()

  _calculateWidth: ->
    width = $(window).width() - $('#left_menu').width()
    unless Alchemy.ElementsWindow.hidden
      width -= $('#alchemy_elements_window').width()
    return width

Alchemy.reloadPreview = ->
  Alchemy.PreviewWindow.refresh()
