export default class ImageCropper {
  constructor(
    box,
    minSize,
    defaultBox,
    aspectRatio,
    trueSize,
    formFieldIds,
    elementId
  ) {
    this.initialized = false

    this.box = box
    this.defaultBox = defaultBox
    this.cropFromField = document.getElementById(formFieldIds[0])
    this.cropSizeField = document.getElementById(formFieldIds[1])
    this.elementId = elementId
    this.dialog = Alchemy.currentDialog()

    const JcropOptions = {
      onSelect: this.update.bind(this),
      setSelect: box,
      aspectRatio,
      minSize,
      boxWidth: 800,
      boxHeight: 600,
      trueSize,
      closed: this.destroy.bind(this)
    }

    if (!this.initialized) {
      this.api = $.Jcrop("#imageToCrop", JcropOptions)
      this.initialized = true
    }

    this.bind()
  }

  update(coords) {
    this.cropFromField.value = Math.round(coords.x) + "x" + Math.round(coords.y)
    this.cropFromField.dispatchEvent(new Event("change"))
    this.cropSizeField.value = Math.round(coords.w) + "x" + Math.round(coords.h)
    this.cropFromField.dispatchEvent(new Event("change"))
  }

  undo() {
    this.api.setSelect(this.box)
  }

  reset() {
    this.api.setSelect(this.defaultBox)
    this.cropFromField.value = ""
    this.cropSizeField.value = ""
  }

  destroy() {
    if (this.api) {
      this.api.destroy()
    }
    this.initialized = false
    return true
  }

  bind() {
    this.dialog.dialog_body.find('button[type="submit"]').click(() => {
      Alchemy.setElementDirty(`[data-element-id='${this.elementId}']`)
      this.dialog.close()
      return false
    })
    this.dialog.dialog_body.find('button[type="reset"]').click(() => {
      this.reset()
      return false
    })
  }
}
