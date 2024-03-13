window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# Adds buttons into a toolbar inside of overlay windows
Alchemy.ToolbarButton = (options) ->
  $btn = $("<sl-tooltip content='#{options.label}' placement='top-#{options.align}'></sl-tooltip>")
  if options.align
    $btn.addClass(options.class)
  if options.buttonId
    $btn.attr(id: options.buttonId)
  $lnk = $("<a class='icon_button' href='#' />")
  if options.hotkey
    $lnk.attr('data-alchemy-hotkey', options.hotkey)
  $lnk.on "click", (e) ->
    e.preventDefault()
    options.onClick(e)
    return
  $lnk.append "<alchemy-icon name='#{options.iconClass}' icon-style='#{options.iconStyle || "line"}'></alchemy-icon>"
  $btn.append $lnk
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
    Alchemy.GUI.init(@element_window)
    @button = $('#element_window_button')
    @button.on "click", =>
      @hide()
      false

    window.requestAnimationFrame =>
      spinner = new Alchemy.Spinner('medium')
      spinner.spin @element_area[0]

    window.addEventListener 'message', (event) =>
      data = event.data
      if data?.message == 'Alchemy.focusElementEditor'
        element = document.getElementById("element_#{data.element_id}")
        Alchemy.ElementsWindow.show()
        element?.focusElement()
      true

    @$body.on "click", (evt) =>
      unless evt.target.closest(".element-editor")
        @element_area.find('.element-editor').removeClass('selected')
        Alchemy.PreviewWindow.postMessage(message: 'Alchemy.blurElements')
      return

    $('#main_content').append(@element_window)
    @show()
    @reload()

  createToolbar: (buttons) ->
    @toolbar = $('<div class="elements-window-toolbar" />')
    buttons.push
      label: Alchemy.t("Collapse all elements")
      iconClass: "contract-up-down-line"
      align: "end"
      class: "right"
      onClick: =>
        $("alchemy-element-editor:not([compact]):not([fixed])").each () ->
          @collapse()
    for btn in buttons
      @toolbar.append Alchemy.ToolbarButton(btn)
    @toolbar.append @collapseAllBtn

  reload: ->
    $.get @url, (data) =>
      @element_area.html data
      Alchemy.SortableElements()
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
      @button.find('alchemy-icon').attr("name", "menu-fold")
      @button.off('click')
      @button.on "click", =>
        @show()
        false
    else
      @button.find('label').text(@options.texts.hideElements)
      @button.find('alchemy-icon').attr("name", "menu-unfold")
      @button.off('click')
      @button.on "click", =>
        @hide()
        false
