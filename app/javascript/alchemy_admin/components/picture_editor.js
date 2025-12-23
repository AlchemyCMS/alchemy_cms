import debounce from "alchemy_admin/utils/debounce"
import max from "alchemy_admin/utils/max"
import { get } from "alchemy_admin/utils/ajax"
import { growl } from "alchemy_admin/growler"

const UPDATE_DELAY = 125
const IMAGE_PLACEHOLDER = '<alchemy-icon name="image" size="xl"></alchemy-icon>'
const THUMBNAIL_SIZE = "160x120"

export class PictureEditor extends HTMLElement {
  constructor() {
    super()

    this.cropFromField = this.querySelector("[data-crop-from]")
    this.cropSizeField = this.querySelector("[data-crop-size]")
    this.pictureIdField = this.querySelector("[data-picture-id]")
    this.targetSizeField = this.querySelector("[data-target-size]")
    this.imageCropperField = this.querySelector("[data-image-cropper]")
    this.image = this.querySelector("img")
    this.pictureThumbnail = this.querySelector("alchemy-picture-thumbnail")
    this.deleteButton = this.querySelector(".picture_tool.delete")
    this.cropLink = this.querySelector(".crop_link")

    this.targetSize = this.targetSizeField.dataset.targetSize
    this.pictureId = this.pictureIdField.value

    // The mutation observer is observing multiple fields that all get updated
    // simultaneously. We only want to update the image once, so we debounce.
    this.update = debounce(() => {
      this.updateImage()
      this.updateCropLink()
    }, UPDATE_DELAY)

    this.deleteButton.addEventListener("click", this.removeImage.bind(this))
  }

  connectedCallback() {
    this.observer = new MutationObserver(this.mutationCallback.bind(this))

    this.observer.observe(this.cropFromField, { attributes: true })
    this.observer.observe(this.cropSizeField, { attributes: true })
    this.observer.observe(this.pictureIdField, { attributes: true })
  }

  disconnectedCallback() {
    this.observer.disconnect()
  }

  mutationCallback(mutationsList) {
    for (const mutation of mutationsList) {
      if ("pictureId" in mutation.target.dataset) {
        this.cropFromField.value = ""
        this.cropSizeField.value = ""
        this.pictureId = mutation.target.value
      }
      this.update()
    }
  }

  updateImage() {
    if (!this.pictureId) return

    this.pictureThumbnail.loading = true
    get(Alchemy.routes.url_admin_picture_path(this.pictureId), {
      crop: this.imageCropperEnabled,
      crop_from: this.cropFrom,
      crop_size: this.cropSize,
      flatten: true,
      size: THUMBNAIL_SIZE
    })
      .then(({ data }) => {
        this.pictureThumbnail.src = data.url
        this.pictureThumbnail.image.alt = data.alt
        this.pictureThumbnail.image.title = data.title
        this.setElementDirty()
      })
      .catch((error) => {
        console.error(error.message || error)
        growl(error.message || error, "error")
      })
  }

  removeImage() {
    this.pictureThumbnail.innerHTML = IMAGE_PLACEHOLDER
    this.pictureIdField.value = ""
    this.image = null
    this.cropLink.classList.add("disabled")
    this.setElementDirty()
  }

  setElementDirty() {
    this.closest(".element-editor").setDirty(this)
  }

  updateCropLink() {
    if (!this.pictureId || !this.imageCropperEnabled) return

    this.cropLink.classList.remove("disabled")

    if (this.cropLink.href.match(/(picture_id=)\d+/)) {
      this.cropLink.href = this.cropLink.href.replace(
        /(picture_id=)\d+/,
        "$1" + this.pictureId
      )
    } else {
      this.cropLink.href = this.cropLink.href + `&picture_id=${this.pictureId}`
    }
  }

  get cropFrom() {
    if (this.cropFromField.value === "") {
      return this.defaultCropFrom.join("x")
    }
    return this.cropFromField.value
  }

  get cropSize() {
    if (this.cropSizeField.value === "") {
      return this.defaultCropSize.join("x")
    }
    return this.cropSizeField.value
  }

  get defaultCropSize() {
    if (!this.imageCropperEnabled) return []

    const mask = this.targetSize.split("x").map((n) => parseInt(n))
    const zoom = max(
      mask[0] / this.imageFileWidth,
      mask[1] / this.imageFileHeight
    )

    return [Math.round(mask[0] / zoom), Math.round(mask[1] / zoom)]
  }

  get defaultCropFrom() {
    if (!this.imageCropperEnabled) return []

    const dimensions = this.defaultCropSize

    return [
      Math.round((this.imageFileWidth - dimensions[0]) / 2),
      Math.round((this.imageFileHeight - dimensions[1]) / 2)
    ]
  }

  get imageFileWidth() {
    return parseInt(this.pictureIdField.dataset.imageFileWidth)
  }

  get imageFileHeight() {
    return parseInt(this.pictureIdField.dataset.imageFileHeight)
  }

  get imageCropperEnabled() {
    return this.targetSizeField.dataset.imageCropper === "true"
  }
}

customElements.define("alchemy-picture-editor", PictureEditor)
