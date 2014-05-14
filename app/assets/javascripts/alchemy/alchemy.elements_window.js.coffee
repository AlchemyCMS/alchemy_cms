window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.ElementsWindow =

  init: (url, options, callback) ->
    @hidden = false
    @element_window = $('<div id="alchemy_elements_window"/>')
    @element_area = $('<div id="element_area"/>')
    @url = url
    @options = options
    @callback = callback
    @element_window.append @element_area
    @button = $('#element_window_button')
    @button.click =>
      @hide()
      false
    height = @resize()
    window.requestAnimationFrame =>
      spinner = Alchemy.Spinner.medium()
      spinner.spin @element_area[0]
    $('#main_content').append(@element_window)
    @reload()

  resize: ->
    height = $(window).height() - 75
    @element_window.css
      height: height
    @element_area.css
      height: height
    height

  reload: ->
    $.get @url, (data) =>
      @element_area.html data
      Alchemy.GUI.init(@element_area)
      if @callback
        @callback.call()
    .fail (xhr, status, error) =>
      Alchemy.AjaxErrorHandler @element_area, xhr.status, status, error

  hide: ->
    @element_window.css(right: -400)
    @hidden = true
    @toggleButton()
    Alchemy.PreviewWindow.resize()

  show: ->
    @element_window.css(right: 0)
    @hidden = false
    @toggleButton()
    Alchemy.PreviewWindow.resize()

  toggleButton: ->
    if @hidden
      @button.find('label').text(@options.texts.showElements)
      @button.off('click')
      @button.click =>
        @show()
        false
    else
      @button.find('label').text(@options.texts.hideElements)
      @button.off('click')
      @button.click =>
        @hide()
        false
