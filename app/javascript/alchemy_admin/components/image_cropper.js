import Cropper from "cropperjs"
import { currentDialog } from "alchemy_admin/dialog"

export class ImageCropper extends HTMLElement {
  #cropper = null
  #cropFromField = null
  #cropSizeField = null

  connectedCallback() {
    this.image = this.querySelector("img")
    this.form = this.querySelector("form")
    this.#cropFromField = document.getElementById(
      this.getAttribute("crop-from-field-id")
    )
    this.#cropSizeField = document.getElementById(
      this.getAttribute("crop-size-field-id")
    )
    this.elementEditor = document.querySelector(
      `[data-element-id='${this.getAttribute("element-id")}']`
    )
    this.form.addEventListener("submit", this.#onSubmit)
    this.form.addEventListener("reset", this.#onReset)
    this.#cropper = new Cropper(this.image, this.cropperOptions)
  }

  disconnectedCallback() {
    this.#cropper?.destroy()
  }

  get cropperOptions() {
    return {
      aspectRatio: this.aspectRatio,
      viewMode: 1,
      zoomable: false,
      checkCrossOrigin: false, // Prevent CORS issues
      checkOrientation: false, // Prevent loading the image via AJAX which can cause CORS issues
      data: this.box
    }
  }

  get aspectRatio() {
    const ratio = this.getAttribute("ratio")
    // NaN lets cropperjs use a free aspect ratio.
    return ratio ? parseFloat(ratio) : NaN
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
      return this.defaultBox
    }
  }

  get defaultBox() {
    const box = JSON.parse(this.getAttribute("default-box"))
    return { x: box[0], y: box[1], width: box[2], height: box[3] }
  }

  update(coords) {
    this.#cropFromField.value = `${coords.x}x${coords.y}`
    this.#cropFromField.dispatchEvent(new Event("change"))
    this.#cropSizeField.value = `${coords.width}x${coords.height}`
    this.#cropSizeField.dispatchEvent(new Event("change"))
  }

  reset() {
    const cropper = this.#cropper
    // Apply the default size. cropperjs clamps the crop box to its maximum size.
    cropper.setData(this.defaultBox)
    // When the default box sits at the maximum crop box size, sub-pixel rounding
    // makes cropperjs treat setData's box as oversized and revert its position
    // (renderCropBox resets top/left to their old values). Re-apply the position
    // in canvas coordinates afterwards – that does not touch the size, so it is
    // not reverted and the mask actually moves to the default box.
    const canvas = cropper.getCanvasData()
    const scale = canvas.width / canvas.naturalWidth
    cropper.setCropBoxData({
      left: canvas.left + this.defaultBox.x * scale,
      top: canvas.top + this.defaultBox.y * scale
    })
    this.update(this.defaultBox)
  }

  #onSubmit = (event) => {
    event.preventDefault()
    this.update(this.#cropper.getData(true))
    this.elementEditor?.setDirty()
    currentDialog()?.close()
  }

  #onReset = (event) => {
    event.preventDefault()
    this.reset()
  }
}

customElements.define("alchemy-image-cropper", ImageCropper)
