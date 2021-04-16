window.Alchemy = {} if typeof (window.Alchemy) is "undefined"

Alchemy.ImageCropper =

  initialized: false

  init: (box, min_size, default_box, ratio, true_size, form_field_ids, element_id) ->
    crop_from_field = $("##{form_field_ids[0]}")
    crop_size_field = $("##{form_field_ids[1]}")
    @element_id = element_id
    options =
      onSelect: (coords) ->
        crop_from_field.val(
          Math.round(coords.x) + "x" + Math.round(coords.y)
        ).trigger("change")
        crop_size_field.val(
          Math.round(coords.w) + "x" + Math.round(coords.h)
        ).trigger("change")
      setSelect: box
      aspectRatio: (if ratio then ratio else `undefined`)
      minSize: (if min_size then min_size else `undefined`)
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
    @dialog = Alchemy.currentDialog()
    @dialog.options.closed = ->
      Alchemy.ImageCropper.destroy()
    @bind()

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

  bind: ->
    @dialog.dialog_body.find('button[type="submit"]').click =>
      Alchemy.setElementDirty("[data-element-id='#{@element_id}']")
      @dialog.close()
      false
    @dialog.dialog_body.find('button[type="reset"]').click =>
      @reset()
      false
    return
