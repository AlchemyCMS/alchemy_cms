import Cropper from "cropperjs.min"

export default class ImageCropper {
  #initialized = false
  #cropper = null
  #cropFromField = null
  #cropSizeField = null

  constructor(image, defaultBox, aspectRatio, formFieldIds, elementId) {
    this.image = image
    this.defaultBox = defaultBox
    this.aspectRatio = aspectRatio
    this.#cropFromField = document.getElementById(formFieldIds[0])
    this.#cropSizeField = document.getElementById(formFieldIds[1])
    this.elementId = elementId
    this.dialog = Alchemy.currentDialog()
    if (this.dialog) {
      this.dialog.options.closed = () => this.destroy()
      this.bind()
    }
    this.init()
  }

  get cropperOptions() {
    return {
      aspectRatio: this.aspectRatio,
      viewMode: 1,
      zoomable: false,
      checkCrossOrigin: false, // Prevent CORS issues
      checkOrientation: false, // Prevent loading the image via AJAX which can cause CORS issues
      data: this.box,
      cropend: () => {
        const data = this.#cropper.getData(true)
        this.update(data)
      }
    }
  }

  get cropFrom() {
    if (this.#cropFromField?.value) {
      return this.#cropFromField.value.split("x").map((v) => parseInt(v))
    }
  }

  get cropSize() {
    if (this.#cropSizeField?.value) {
      return this.#cropSizeField.value.split("x").map((v) => parseInt(v))
    }
  }

  get box() {
    if (this.cropFrom && this.cropSize) {
      return {
        x: this.cropFrom[0],
        y: this.cropFrom[1],
        width: this.cropSize[0],
        height: this.cropSize[1]
      }
    } else {
      return this.defaultBoxSize
    }
  }

  get defaultBoxSize() {
    return {
      x: this.defaultBox[0],
      y: this.defaultBox[1],
      width: this.defaultBox[2],
      height: this.defaultBox[3]
    }
  }

  init() {
    if (!this.#initialized) {
      this.#cropper = new Cropper(this.image, this.cropperOptions)
      this.#initialized = true
    }
  }

  update(coords) {
    this.#cropFromField.value = `${coords.x}x${coords.y}`
    this.#cropFromField.dispatchEvent(new Event("change"))
    this.#cropSizeField.value = `${coords.width}x${coords.height}`
    this.#cropSizeField.dispatchEvent(new Event("change"))
  }

  reset() {
    this.#cropper.setData(this.defaultBoxSize)
    this.update(this.defaultBoxSize)
  }

  destroy() {
    if (this.#cropper) {
      this.#cropper.destroy()
    }
    this.#initialized = false
    return true
  }

  bind() {
    this.dialog.dialog_body.find('button[type="submit"]').on("click", () => {
      const elementEditor = document.querySelector(
        `[data-element-id='${this.elementId}']`
      )
      elementEditor.setDirty()
      this.dialog.close()
      return false
    })
    this.dialog.dialog_body.find('button[type="reset"]').on("click", () => {
      this.reset()
      return false
    })
  }
}
