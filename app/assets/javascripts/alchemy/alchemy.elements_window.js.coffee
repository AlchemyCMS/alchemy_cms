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
    return
  $lnk.append "<i class='icon fas fa-#{options.iconClass} fa-fw' />"
  $btn.append $lnk
  $btn.append "<br><label>#{options.label}</label>"
  $btn

Alchemy.ElementsWindow =

  init: (url, options, callback) ->
    @hidden = false
    @$body = $('body')
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
    window.requestAnimationFrame =>
      spinner = new Alchemy.Spinner('medium')
      spinner.spin @element_area[0]
    $('#main_content').append(@element_window)
    @show()
    @reload()

  createToolbar: (buttons) ->
    @toolbar = $('<div id="overlay_toolbar"/>')
    for btn in buttons
      @toolbar.append Alchemy.ToolbarButton(btn)
    @toolbar

  reload: ->
    $.get @url, (data) =>
      @element_area.html data
      Alchemy.GUI.init(@element_area)
      Alchemy.fileEditors(@element_area.find(".essence_file, .essence_video, .essence_audio, .ingredient-editor.file, .ingredient-editor.audio, .ingredient-editor.video").selector)
      Alchemy.pictureEditors(@element_area.find(".essence_picture, .ingredient-editor.picture").selector)
      if @callback
        @callback.call()
    .fail (xhr, status, error) =>
      Alchemy.Dialog::show_error(xhr, error, @element_area)

  hide: ->
    @$body.removeClass('elements-window-visible');
    @hidden = true
    @toggleButton()

  show: ->
    @$body.addClass('elements-window-visible');
    @hidden = false
    @toggleButton()

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
