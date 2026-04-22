import { FileUpload } from "alchemy_admin/components/uploader/file_upload"
import { formatFileSize } from "alchemy_admin/utils/format"
import { translate } from "alchemy_admin/i18n"

const template = (buttonLabel, fileCount) => `
  <sl-progress-bar value="0"></sl-progress-bar>
  <div class="overall-progress-value">
    <span class="value-text"></span>

    <sl-tooltip content="${buttonLabel}">
      <button class="icon_button" aria-label="${buttonLabel}">
        <alchemy-icon name="close"></alchemy-icon>
      </button>
    </sl-tooltip>
  </div>
  <div class="single-uploads" style="--progress-columns: ${
    fileCount > 3 ? 3 : fileCount
  }"></div>
  <div class="overall-upload-value value-text"></div>
`

export class Progress extends HTMLElement {
  // public — accessed by Uploader and tests
  fileCount = 0

  // private — backing state and internals
  #fileUploads = []
  #buttonLabel = translate("Cancel all uploads")
  #actionButton = null
  #visible = false
  #handleFileChange = () => this.#updateView()

  connectedCallback() {
    this.innerHTML = template(this.#buttonLabel, this.fileCount)
    this.visible = true

    this.#actionButton = this.querySelector("button")
    this.#actionButton.addEventListener("click", () => {
      if (this.finished) {
        this.onComplete(this.status)
      } else {
        this.cancel()
      }
    })

    this.#fileUploads.forEach((fileUpload) => {
      this.querySelector(".single-uploads").append(fileUpload)
    })

    this.#updateView()
    this.addEventListener("Alchemy.FileUpload.Change", this.#handleFileChange)
  }

  disconnectedCallback() {
    this.removeEventListener(
      "Alchemy.FileUpload.Change",
      this.#handleFileChange
    )
  }

  /**
   * Initialize the component with file uploads
   * @param {FileUpload[]} fileUploads
   */
  initialize(fileUploads = []) {
    this.#fileUploads = fileUploads
    this.fileCount = fileUploads.length
  }

  /**
   * cancel requests in all remaining uploads
   */
  cancel() {
    this.#activeUploads().forEach((upload) => {
      upload.cancel()
    })
    this.#setupCloseButton()
  }

  /**
   * a complete hook to allow the uploader to react and trigger an event
   * it would be possible to trigger the event here, but the dispatching would happen
   * in the scope of that component and can't be cached o uploader - component level
   */
  onComplete(_status) {}

  /**
   * get all active upload components
   * @returns {FileUpload[]}
   */
  #activeUploads() {
    return this.#fileUploads.filter((upload) => upload.active)
  }

  /**
   * replace cancel button to be the close button
   */
  #setupCloseButton() {
    this.#buttonLabel = translate("Close")
    this.#actionButton.ariaLabel = this.#buttonLabel
    this.#actionButton.parentElement.content = this.#buttonLabel // update tooltip content
  }

  /**
   * @param {string} field
   * @returns {number}
   */
  #sumFileProgresses(field) {
    return this.#activeUploads().reduce(
      (accumulator, upload) => upload[field] + accumulator,
      0
    )
  }

  /**
   * don't render the whole element new, because it would prevent selecting buttons
   */
  #updateView() {
    const status = this.status
    this.className = status

    // update progress bar
    this.progressElement.value = this.totalProgress
    this.progressElement.toggleAttribute(
      "indeterminate",
      status === "upload-finished"
    )

    // show progress in file size and percentage
    this.querySelector(`.overall-progress-value > span`).textContent =
      this.overallProgressValue
    this.querySelector(`.overall-upload-value`).textContent =
      this.overallUploadSize

    if (this.finished) {
      this.#setupCloseButton()
      this.onComplete(status)
    } else {
      this.visible = true
    }
  }

  /**
   * @returns {boolean}
   */
  get finished() {
    return this.#activeUploads().every((entry) => entry.finished)
  }

  /**
   * @returns {string}
   */
  get overallUploadSize() {
    const uploadedFileCount = this.#activeUploads().filter(
      (fileProgress) => fileProgress.value >= 100
    ).length
    const overallProgressValue = `${
      this.totalProgress
    }% (${uploadedFileCount} / ${this.#activeUploads().length})`

    return `${formatFileSize(
      this.#sumFileProgresses("progressEventLoaded")
    )} / ${formatFileSize(this.#sumFileProgresses("progressEventTotal"))}`
  }

  /**
   * @returns {string}
   */
  get overallProgressValue() {
    const uploadedFileCount = this.#activeUploads().filter(
      (fileProgress) => fileProgress.value >= 100
    ).length
    return `${this.totalProgress}% (${uploadedFileCount} / ${
      this.#activeUploads().length
    })`
  }

  /**
   * @returns {HTMLProgressElement|undefined}
   */
  get progressElement() {
    return this.querySelector("sl-progress-bar")
  }

  /**
   * get status of file progresses and accumulate the overall status
   * @returns {string}
   */
  get status() {
    const uploadsStatuses = this.#activeUploads().map(
      (upload) => upload.className
    )

    // mark as failed, if any upload failed
    if (uploadsStatuses.includes("failed")) {
      return "failed"
    }

    // no active upload means that every upload was canceled
    if (uploadsStatuses.length === 0) {
      return "canceled"
    }

    // all uploads are successful or upload-finished or in-progress
    if (uploadsStatuses.every((entry) => entry === uploadsStatuses[0])) {
      return uploadsStatuses[0]
    }

    return "in-progress"
  }

  /**
   * @returns {number}
   */
  get totalProgress() {
    const totalSize = this.#activeUploads().reduce(
      (accumulator, upload) => accumulator + upload.file.size,
      0
    )
    let totalProgress = Math.ceil(
      this.#activeUploads().reduce((accumulator, upload) => {
        const weight = upload.file.size / totalSize
        return upload.value * weight + accumulator
      }, 0)
    )
    // prevent rounding errors
    if (totalProgress > 100) {
      totalProgress = 100
    }
    return totalProgress
  }

  /**
   * @returns {boolean}
   */
  get visible() {
    return this.#visible
  }

  /**
   * @param {boolean} visible
   */
  set visible(visible) {
    this.classList.toggle("visible", visible)
    this.#visible = visible
  }
}

customElements.define("alchemy-upload-progress", Progress)
