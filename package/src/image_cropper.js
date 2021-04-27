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
    this.minSize = minSize
    this.defaultBox = defaultBox
    this.aspectRatio = aspectRatio
    this.trueSize = trueSize
    this.cropFromField = document.getElementById(formFieldIds[0])
    this.cropSizeField = document.getElementById(formFieldIds[1])
    this.elementId = elementId
    this.dialog = Alchemy.currentDialog()

    this.init()
    this.bind()
  }

  get jcropOptions() {
    return {
      onSelect: this.update.bind(this),
      setSelect: this.box,
      aspectRatio: this.aspectRatio,
      minSize: this.minSize,
      boxWidth: 800,
      boxHeight: 600,
      trueSize: this.trueSize,
      closed: this.destroy.bind(this)
    }
  }

  init() {
    this.setBoxFromCropValues()
    if (!this.initialized) {
      this.api = $.Jcrop("#imageToCrop", this.jcropOptions)
      this.initialized = true
    }
  }

  setBoxFromCropValues() {
    if (this.cropFromField.value && this.cropSizeField.value) {
      const cropFrom = this.cropFromField.value
        .split("x")
        .map((v) => parseInt(v))
      const cropSize = this.cropSizeField.value
        .split("x")
        .map((v) => parseInt(v))
      this.box = [
        cropFrom[0],
        cropFrom[1],
        cropSize[0],
        cropSize[1] + cropFrom[1]
      ]
    }
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
    const box = this.defaultBox
    this.api.setSelect(box)
    this.cropFromField.value = `${box[0]}x${box[1]}`
    this.cropSizeField.value = `${box[2]}x${box[3] - box[1]}`
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
