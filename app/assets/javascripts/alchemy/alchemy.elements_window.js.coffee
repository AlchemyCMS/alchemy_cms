window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# Adds buttons into a toolbar inside of overlay windows
Alchemy.ToolbarButton = (options) ->
  $btn = $('<div class="button_with_label" />')
  if options.buttonId
    $btn.attr(id: options.buttonId)
  $lnk = $("<a title='#{options.title}' class='icon_button' href='#' />")
  if options.hotkey
    $lnk.attr('data-alchemy-hotkey', options.hotkey)
  $lnk.click (e) ->
    e.preventDefault()
    options.onClick(e)
    false
  $lnk.append "<span class='#{options.iconClass}' />"
  $btn.append $lnk
  $btn.append "<br><label>#{options.label}</label>"
  $btn

Alchemy.ElementsWindow =

  init: (url, options, callback) ->
    @hidden = false
    @element_window = $('<div id="alchemy_elements_window"/>')
    @element_area = $('<div id="element_area"/>')
    @url = url
    @options = options
    @callback = callback
    @element_window.append @createToolbar(options.toolbarButtons)
    @element_window.append @element_area
    @button = $('#element_window_button')
    @button.click =>
      @hide()
      false
    height = @resize()
    window.requestAnimationFrame =>
      spinner = new Alchemy.Spinner('medium')
      spinner.spin @element_area[0]
    $('#main_content').append(@element_window)
    @reload()

  createToolbar: (buttons) ->
    @toolbar = $('<div id="overlay_toolbar"/>')
    for btn in buttons
      @toolbar.append Alchemy.ToolbarButton(btn)
    @toolbar

  resize: ->
    height = $(window).height() - 73
    @element_window.css
      height: height
    @element_area.css
      height: height - 46
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
