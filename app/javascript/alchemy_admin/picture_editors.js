import debounce from "alchemy_admin/utils/debounce"
import max from "alchemy_admin/utils/max"
import { get } from "alchemy_admin/utils/ajax"
import { growl } from "alchemy_admin/growler"
import ImageLoader from "alchemy_admin/image_loader"

const UPDATE_DELAY = 125
const IMAGE_PLACEHOLDER = '<alchemy-icon name="image" size="xl"></alchemy-icon>'
const THUMBNAIL_SIZE = "160x120"

export class PictureEditor {
  constructor(container) {
    this.container = container
    this.cropFromField = container.querySelector("[data-crop-from]")
    this.cropSizeField = container.querySelector("[data-crop-size]")
    this.pictureIdField = container.querySelector("[data-picture-id]")
    this.targetSizeField = container.querySelector("[data-target-size]")
    this.imageCropperField = container.querySelector("[data-image-cropper]")
    this.image = container.querySelector("img")
    this.thumbnailBackground = container.querySelector(".thumbnail_background")
    this.deleteButton = container.querySelector(".picture_tool.delete")
    this.cropLink = container.querySelector(".crop_link")

    this.targetSize = this.targetSizeField.dataset.targetSize
    this.pictureId = this.pictureIdField.value

    if (this.image) {
      this.imageLoader = new ImageLoader(this.image)
    }

    // The mutation observer is observing multiple fields that all get updated
    // simultaneously. We only want to update the image once, so we debounce.
    this.update = debounce(() => {
      this.updateImage()
      this.updateCropLink()
    }, UPDATE_DELAY)

    this.deleteButton.addEventListener("click", this.removeImage.bind(this))
  }

  observe() {
    const observer = new MutationObserver(this.mutationCallback.bind(this))

    observer.observe(this.cropFromField, { attributes: true })
    observer.observe(this.cropSizeField, { attributes: true })
    observer.observe(this.pictureIdField, { attributes: true })
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

    this.ensureImage()
    this.image.removeAttribute("alt")
    this.image.removeAttribute("src")
    this.imageLoader.load(true)
    get(Alchemy.routes.url_admin_picture_path(this.pictureId), {
      crop: this.imageCropperEnabled,
      crop_from: this.cropFrom,
      crop_size: this.cropSize,
      flatten: true,
      size: THUMBNAIL_SIZE
    })
      .then(({ data }) => {
        this.image.src = data.url
        this.image.alt = data.alt
        this.image.title = data.title
        this.setElementDirty()
      })
      .catch((error) => {
        console.error(error.message || error)
        growl(error.message || error, "error")
      })
  }

  ensureImage() {
    const img = new Image()
    this.thumbnailBackground.replaceChildren(img)
    this.image = img
    this.imageLoader = new ImageLoader(img)
  }

  removeImage() {
    this.thumbnailBackground.innerHTML = IMAGE_PLACEHOLDER
    this.pictureIdField.value = ""
    this.image = null
    this.cropLink.classList.add("disabled")
    this.setElementDirty()
  }

  setElementDirty() {
    this.container.closest(".element-editor").setDirty(this.container)
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

export default function init(selector) {
  document.querySelectorAll(selector).forEach((node) => {
    const thumbnail = new PictureEditor(node)
    thumbnail.observe()
  })
}
