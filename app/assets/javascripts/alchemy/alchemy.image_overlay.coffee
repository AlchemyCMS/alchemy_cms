class window.Alchemy.ImageOverlay extends Alchemy.Dialog

  constructor: (url) ->
    @options =
      draggable: false
      ready: (dialog) ->
        Alchemy.ImageLoader(dialog)
        return
    super(url, @options)
    return

  init: ->
    $('#zoomed_picture_background').click (e) =>
      e.stopPropagation()
      return if e.target.nodeName == 'IMG'
      @close()
      false
    super()

  build: ->
    @dialog_container = $('<div class="alchemy-image-overlay-container" />')
    @dialog = $('<div class="alchemy-image-overlay-dialog" />')
    @dialog_body = $('<div class="alchemy-image-overlay-body" />')
    @close_button = $('<a class="alchemy-image-overlay-close"><span class="icon close small"></span></a>')
    @dialog.append(@close_button)
    @dialog.append(@dialog_body)
    @dialog_container.append(@dialog)
    @overlay = $('<div class="alchemy-image-overlay" />')
    @$body.append(@overlay)
    @$body.append(@dialog_container)
    @dialog
