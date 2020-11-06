window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.PreviewWindow =
  MIN_WIDTH: 240
  HEIGHT: 75 # Top menu height

  init: (previewUrl) ->
    @select = document.querySelector('#preview_url')
    @previewUrl = @_getCurrentPreviewUrl() || previewUrl[1]
    $iframe = $("<iframe name=\"alchemy_preview_window\" src=\"#{@previewUrl}\" id=\"alchemy_preview_window\" frameborder=\"0\"/>")
    $reload = $('#reload_preview_button')
    @_showSpinner()
    $iframe.load =>
      @_hideSpinner()
    $('body').append($iframe)
    @currentWindow = $iframe
    @_bindReloadButton()
    if @select
      @select.value = @previewUrl
      @_bindSelect()
    return

  resize: (width) ->
    width = @MIN_WIDTH if width < @MIN_WIDTH
    @currentWidth = width
    @currentWindow.css
      width: width

  refresh: (callback) ->
    $iframe = $('#alchemy_preview_window')
    @_showSpinner()
    # We need to be sure that no load event is binded on the preview frame.
    $iframe.off('load')
    $iframe.load (e) =>
      @_hideSpinner()
      if callback
        callback.call(e, $iframe)
    $iframe.attr('src', @previewUrl)
    true

  postMessage: (data) ->
    frameWindow = @currentWindow[0].contentWindow
    frameWindow.postMessage(data, "*")

  _showSpinner: ->
    @reload = $('#reload_preview_button')
    @spinner = new Alchemy.Spinner('small')
    @reload.html @spinner.spin().el

  _hideSpinner: ->
    @spinner.stop()
    @reload.html('<i class="icon fas fa-redo fa-fw"></i>')

  _bindReloadButton: ->
    $reload = $('#reload_preview_button')
    key 'alt+r', =>
      @refresh()
    $reload.click (e) =>
      e.preventDefault()
      @refresh()

  _getCurrentPreviewUrl: ->
    if @select
      option = Array.from(@select.options).find (o) =>
        o.text == window.localStorage.getItem("alchemyPreview")
      if option
        option.value
      else
        null
    else
      null

  _bindSelect: ->
    $(@select).change (e) =>
      @previewUrl = e.target.value
      option = e.target.querySelector("option[value='#{@previewUrl}']")
      window.localStorage.setItem("alchemyPreview", option.text)
      @refresh()
      return

Alchemy.reloadPreview = ->
  Alchemy.PreviewWindow.refresh()
