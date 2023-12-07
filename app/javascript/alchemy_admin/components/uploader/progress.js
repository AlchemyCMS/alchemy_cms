import { AlchemyHTMLElement } from "../alchemy_html_element"
import { FileUpload } from "./file_upload"
import { formatFileSize } from "../../utils/format"

export class Progress extends AlchemyHTMLElement {
  #visible = false

  /**
   * @param {FileUpload[]} fileUploads
   */
  constructor(fileUploads = []) {
    super()
    this.fileUploads = fileUploads
    this.fileCount = fileUploads.length
    this.className = "in-progress"
    this.visible = true
  }

  connected() {
    this._updateView()
    this.addEventListener("Alchemy.FileUpload.Change", () => this._updateView())
  }

  render() {
    return `
      <sl-progress-bar value="0"></sl-progress-bar>
      <div class="overall-progress-value value-text"></div>
      <div class="single-uploads" style="--progress-columns: ${
        this.fileCount > 3 ? 3 : this.fileCount
      }"></div>
      <div class="overall-upload-value value-text"></div>
    `
  }

  /**
   * append file progress - components for each file
   */
  afterRender() {
    this.fileUploads.forEach((fileUpload) => {
      this.querySelector(".single-uploads").append(fileUpload)
    })
  }

  /**
   * don't render the whole element new, because it would prevent selecting buttons
   * @private
   */
  _updateView() {
    const totalSize = this._activeUploads().reduce(
      (accumulator, upload) => accumulator + upload.file.size,
      0
    )
    const totalProgress = Math.ceil(
      this._activeUploads().reduce((accumulator, upload) => {
        const weight = upload.file.size / totalSize
        return upload.value * weight + accumulator
      }, 0)
    )
    const uploadedFileCount = this._activeUploads().filter(
      (fileProgress) => fileProgress.value >= 100
    ).length
    const overallProgressValue = `${totalProgress}% (${uploadedFileCount} / ${
      this._activeUploads().length
    })`
    const overallUploadSize = `${formatFileSize(
      this._sumFileProgresses("progressEventLoaded")
    )} / ${formatFileSize(this._sumFileProgresses("progressEventTotal"))}`

    const status = this.status

    this.progressElement.value = totalProgress
    this.progressElement.toggleAttribute(
      "indeterminate",
      status === "upload-finished"
    )
    this.querySelector(`.overall-progress-value`).textContent =
      overallProgressValue
    this.querySelector(`.overall-upload-value`).textContent = overallUploadSize

    if (this.finished) {
      this.onComplete()
    }

    this.className = status
    this.visible = true
  }

  /**
   * a complete hook to allow the uploader to react and trigger an event
   * it would be possible to trigger the event here, but the dispatching would happen
   * in the scope of that component and can't be cached o uploader - component level
   */
  onComplete() {}

  /**
   * @returns {boolean}
   */
  get finished() {
    return this._activeUploads().every((entry) => entry.finished)
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

    if (uploadsStatuses.includes("failed")) {
      return "failed"
    }

    // all uploads are successful or upload-finished or in-progress
    if (uploadsStatuses.every((entry) => entry === uploadsStatuses[0])) {
      return uploadsStatuses[0]
    }

    return "in-progress"
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

  _activeUploads() {
    return this.fileUploads.filter((upload) => upload.active)
  }
}

customElements.define("alchemy-upload-progress", Progress)
