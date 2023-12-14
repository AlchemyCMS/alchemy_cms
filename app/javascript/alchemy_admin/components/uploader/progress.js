import { AlchemyHTMLElement } from "../alchemy_html_element"
import { FileUpload } from "./file_upload"
import { formatFileSize } from "../../utils/format"
import { translate } from "../../i18n"

export class Progress extends AlchemyHTMLElement {
  #visible = false

  /**
   * @param {FileUpload[]} fileUploads
   */
  constructor(fileUploads = []) {
    super()
    this.buttonLabel = translate("Cancel all uploads")
    this.fileUploads = fileUploads
    this.fileCount = fileUploads.length
    this.className = "in-progress"
    this.visible = true
    this.handleFileChange = () => this._updateView()
  }

  /**
   * append file progress - components for each file
   */
  afterRender() {
    this.actionButton = this.querySelector("button")
    this.actionButton.addEventListener("click", () => {
      if (this.finished) {
        this.onComplete(this.status)
        this.visible = false
      } else {
        this.cancel()
      }
    })

    this.fileUploads.forEach((fileUpload) => {
      this.querySelector(".single-uploads").append(fileUpload)
    })
  }

  /**
   * cancel requests in all remaining uploads
   */
  cancel() {
    this._activeUploads().forEach((upload) => {
      upload.cancel()
    })
    this._setupCloseButton()
  }

  /**
   * update view and register change event
   */
  connected() {
    this._updateView()
    this.addEventListener("Alchemy.FileUpload.Change", this.handleFileChange)
  }

  /**
   * deregister file upload change - event
   */
  disconnected() {
    this.removeEventListener("Alchemy.FileUpload.Change", this.handleFileChange)
  }

  /**
   * a complete hook to allow the uploader to react and trigger an event
   * it would be possible to trigger the event here, but the dispatching would happen
   * in the scope of that component and can't be cached o uploader - component level
   */
  onComplete(_status) {}

  render() {
    return `
      <sl-progress-bar value="0"></sl-progress-bar>
      <div class="overall-progress-value">
        <span class="value-text"></span>

        <sl-tooltip content="${this.buttonLabel}">
          <button class="icon_button" aria-label="${this.buttonLabel}">
            <i class="icon ri-close-line ri-fw"></i>
          </button>
        </sl-tooltip>
      </div>
      <div class="single-uploads" style="--progress-columns: ${
        this.fileCount > 3 ? 3 : this.fileCount
      }"></div>
      <div class="overall-upload-value value-text"></div>
    `
  }

  /**
   * get all active upload components
   * @returns {FileUpload[]}
   * @private
   */
  _activeUploads() {
    return this.fileUploads.filter((upload) => upload.active)
  }

  /**
   * replace cancel button to be the close button
   * @private
   */
  _setupCloseButton() {
    this.buttonLabel = translate("Close")
    this.actionButton.ariaLabel = this.buttonLabel
    this.actionButton.parentElement.content = this.buttonLabel // update tooltip content
  }

  /**
   * @param {string} field
   * @returns {number}
   * @private
   */
  _sumFileProgresses(field) {
    return this._activeUploads().reduce(
      (accumulator, upload) => upload[field] + accumulator,
      0
    )
  }

  /**
   * don't render the whole element new, because it would prevent selecting buttons
   * @private
   */
  _updateView() {
    const status = this.status

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
      this._setupCloseButton()
      this.onComplete(status)
    }

    this.className = status
    this.visible = true
  }

  /**
   * @returns {boolean}
   */
  get finished() {
    return this._activeUploads().every((entry) => entry.finished)
  }

  /**
   * @returns {string}
   */
  get overallUploadSize() {
    const uploadedFileCount = this._activeUploads().filter(
      (fileProgress) => fileProgress.value >= 100
    ).length
    const overallProgressValue = `${
      this.totalProgress
    }% (${uploadedFileCount} / ${this._activeUploads().length})`

    return `${formatFileSize(
      this._sumFileProgresses("progressEventLoaded")
    )} / ${formatFileSize(this._sumFileProgresses("progressEventTotal"))}`
  }

  /**
   * @returns {string}
   */
  get overallProgressValue() {
    const uploadedFileCount = this._activeUploads().filter(
      (fileProgress) => fileProgress.value >= 100
    ).length
    return `${this.totalProgress}% (${uploadedFileCount} / ${
      this._activeUploads().length
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
    const uploadsStatuses = this._activeUploads().map(
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
    const totalSize = this._activeUploads().reduce(
      (accumulator, upload) => accumulator + upload.file.size,
      0
    )
    let totalProgress = Math.ceil(
      this._activeUploads().reduce((accumulator, upload) => {
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
