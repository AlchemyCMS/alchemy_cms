window.Alchemy = {} if typeof (window.Alchemy) is "undefined"

Alchemy.ImageCropper =

  initialized: false

  init: (box, size_x, size_y, default_box, ratio, true_size) ->
    crop_from_field = $("#essence_picture_crop_from")
    crop_size_field = $("#essence_picture_crop_size")
    options =
      onSelect: (coords) ->
        crop_from_field.val coords.x + "x" + coords.y
        crop_size_field.val coords.w + "x" + coords.h
      setSelect: box
      aspectRatio: (if ratio then ratio else `undefined`)
      minSize: [size_x, size_y]
      boxWidth: 800
      boxHeight: 600
      trueSize: true_size
    Alchemy.ImageCropper.box = box
    Alchemy.ImageCropper.default_box = default_box
    Alchemy.ImageCropper.crop_from_field = crop_from_field
    Alchemy.ImageCropper.crop_size_field = crop_size_field
    unless Alchemy.ImageCropper.initialized
      Alchemy.ImageCropper.api = $.Jcrop("#imageToCrop", options)
      Alchemy.ImageCropper.initialized = true
    dialog = Alchemy.currentDialog()
    if dialog?
      dialog.options.closed = ->
        Alchemy.ImageCropper.destroy()

  undo: ->
    Alchemy.ImageCropper.api.setSelect Alchemy.ImageCropper.box

  reset: ->
    Alchemy.ImageCropper.api.setSelect Alchemy.ImageCropper.default_box
    Alchemy.ImageCropper.crop_from_field.val ""
    Alchemy.ImageCropper.crop_size_field.val ""

  destroy: ->
    if Alchemy.ImageCropper.api
      Alchemy.ImageCropper.api.destroy()
    Alchemy.ImageCropper.initialized = false
    true
