export default class ImageCropper {
  constructor(
    minSize,
    defaultBox,
    aspectRatio,
    trueSize,
    formFieldIds,
    elementId
  ) {
    this.initialized = false

    this.minSize = minSize
    this.defaultBox = defaultBox
    this.aspectRatio = aspectRatio
    this.trueSize = trueSize
    this.cropFromField = document.getElementById(formFieldIds[0])
    this.cropSizeField = document.getElementById(formFieldIds[1])
    this.elementId = elementId
    this.dialog = Alchemy.currentDialog()
    this.dialog.options.closed = this.destroy

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

  get cropFrom() {
    if (this.cropFromField.value) {
      return this.cropFromField.value.split("x").map((v) => parseInt(v))
    }
  }

  get cropSize() {
    if (this.cropSizeField.value) {
      return this.cropSizeField.value.split("x").map((v) => parseInt(v))
    }
  }

  get box() {
    if (this.cropFrom && this.cropSize) {
      return [
        this.cropFrom[0],
        this.cropFrom[1],
        this.cropFrom[0] + this.cropSize[0],
        this.cropFrom[1] + this.cropSize[1]
      ]
    } else {
      return this.defaultBox
    }
  }

  init() {
    if (!this.initialized) {
      this.api = $.Jcrop("#imageToCrop", this.jcropOptions)
      this.initialized = true
    }
  }

  update(coords) {
    this.cropFromField.value = Math.round(coords.x) + "x" + Math.round(coords.y)
    this.cropFromField.dispatchEvent(new Event("change"))
    this.cropSizeField.value = Math.round(coords.w) + "x" + Math.round(coords.h)
    this.cropFromField.dispatchEvent(new Event("change"))
  }

  reset() {
    this.api.setSelect(this.defaultBox)
    this.cropFromField.value = `${this.box[0]}x${this.box[1]}`
    this.cropSizeField.value = `${this.box[2]}x${this.box[3] - this.box[1]}`
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
