class window.Alchemy.ImageOverlay extends Alchemy.Dialog

  constructor: (url) ->
    super(url, @options)
    return

  init: ->
    Alchemy.ImageLoader(@dialog_body[0])
    $('.zoomed-picture-background').on "click", (e) =>
      e.stopPropagation()
      return if e.target.nodeName == 'IMG'
      @close()
      false
    $('.picture-overlay-handle').on "click", (e) =>
      @dialog.toggleClass('hide-form')
      false
    @$previous = $('.previous-picture')
    @$next = $('.next-picture')
    @$document.keydown (e) =>
      if e.target.nodeName == 'INPUT' || e.target.nodeName == 'TEXTAREA'
        return true
      switch e.which
        when 37
          @previous()
          false
        when 39
          @next()
          false
        else
          true
    super()

  previous: ->
    @$previous[0]?.click()
    return

  next: ->
    @$next[0]?.click()
    return

  build: ->
    @dialog_container = $('<div class="alchemy-image-overlay-container" />')
    @dialog = $('<div class="alchemy-image-overlay-dialog" />')
    @dialog_body = $('<div class="alchemy-image-overlay-body" />')
    @close_button = $('<a class="alchemy-image-overlay-close">
      <alchemy-icon name="close" size="xl"></alchemy-icon>
    </a>')
    @dialog.append(@close_button)
    @dialog.append(@dialog_body)
    @dialog_container.append(@dialog)
    @overlay = $('<div class="alchemy-image-overlay" />')
    @$body.append(@overlay)
    @$body.append(@dialog_container)
    @dialog
