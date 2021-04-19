import debounce from "lodash/debounce"
import ajax from "./utils/ajax"
import ImageLoader from "./image_loader"

const UPDATE_DELAY = 250
const IMAGE_PLACEHOLDER = '<i class="icon far fa-image fa-fw"></i>'
const EMPTY_IMAGE = '<img src="" class="img_paddingtop" />'

class PictureEditor {
  constructor(container) {
    this.container = container
    this.cropFromField = container.querySelector("[data-crop-from]")
    this.cropSizeField = container.querySelector("[data-crop-size]")
    this.pictureIdField = container.querySelector("[data-picture-id]")
    this.sizeField = container.querySelector("[data-size]")
    this.image = container.querySelector("img")
    this.thumbnailBackground = container.querySelector(".thumbnail_background")
    this.deleteButton = container.querySelector(".picture_tool.delete")
    this.cropLink = container.querySelector(".crop_link")

    this.cropFrom = this.cropFromField.value
    this.cropSize = this.cropSizeField.value
    this.size = this.sizeField.dataset.size
    this.pictureId = this.pictureIdField.value

    if (this.image) {
      this.imageLoader = new ImageLoader(this.image)
    }

    this.update = debounce(() => {
      this.updateImage()
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
      if ("cropFrom" in mutation.target.dataset) {
        this.cropFrom = mutation.target.value
      } else if ("cropSize" in mutation.target.dataset) {
        this.cropSize = mutation.target.value
      } else if ("pictureId" in mutation.target.dataset) {
        this.pictureId = mutation.target.value
      }

      if (this.pictureId) {
        this.update()

        if (this.cropFrom && this.cropSize) {
          this.updateCropLink()
        }
      }
    }
  }

  updateImage() {
    this.ensureImage()
    this.image.removeAttribute("src")
    this.imageLoader.load()
    ajax("GET", `/admin/pictures/${this.pictureId}/url`, {
      crop: true,
      crop_from: this.cropFrom,
      crop_size: this.cropSize,
      flatten: true,
      size: this.size
    })
      .then(({ data }) => {
        this.image.src = data.url
      })
      .catch((error) => {
        console.error(error.message || error)
        Alchemy.growl(error.message || error, "error")
      })
  }

  ensureImage() {
    if (this.image) return

    this.thumbnailBackground.innerHTML = EMPTY_IMAGE
    this.image = this.container.querySelector("img")
    this.imageLoader = new ImageLoader(this.image)
  }

  removeImage() {
    this.thumbnailBackground.innerHTML = IMAGE_PLACEHOLDER
    this.pictureIdField.value = ""
    this.image = null
    this.cropLink.classList.add("disabled")
    Alchemy.setElementDirty(this.container.closest(".element-editor"))
  }

  updateCropLink() {
    this.cropLink.classList.remove("disabled")
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
}

export default function init(selector) {
  document.querySelectorAll(selector).forEach((node) => {
    const thumbnail = new PictureEditor(node)
    thumbnail.observe()
  })
}
