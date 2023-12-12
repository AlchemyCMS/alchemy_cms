/**
 * @typedef {object} PersistedFile
 * @property {string} name
 * @property {number} size
 */
import { AlchemyHTMLElement } from "./alchemy_html_element"
import { Progress } from "./uploader/progress"
import { FileUpload } from "./uploader/file_upload"
import { translate } from "alchemy_admin/i18n"
import { getToken } from "alchemy_admin/utils/ajax"

export class Uploader extends AlchemyHTMLElement {
  static properties = {
    dropzone: { default: false }
  }

  connected() {
    this.fileInput.addEventListener("change", (event) => {
      this._uploadFiles(Array.from(event.target.files))
    })
    if (this.dropzone) {
      this._dragAndDropBehavior()
    }
  }

  /**
   * add dragover class to indicate, if the file is draggable
   * @private
   */
  _dragAndDropBehavior() {
    const dropzoneElement = document.querySelector(this.dropzone)
    let isDraggedOver = false

    const toggleDropzoneClass = (enabled) => {
      if (isDraggedOver !== enabled) {
        isDraggedOver = enabled
        dropzoneElement.classList.toggle("dragover")
      }
    }

    dropzoneElement.addEventListener("dragleave", () =>
      toggleDropzoneClass(false)
    )
    dropzoneElement.addEventListener("drop", async (event) => {
      event.preventDefault()
      toggleDropzoneClass(false)

      const files = [...event.dataTransfer.items].map((item) =>
        item.getAsFile()
      )

      this._uploadFiles(files)
    })

    dropzoneElement.addEventListener("dragover", (event) => {
      event.preventDefault() // dragover has to be disabled to use the custom drop event
      toggleDropzoneClass(true)
    })
  }

  /**
   * @param {File[]} files
   * @private
   */
  _uploadFiles(files) {
    // prepare file progress bars and server request
    let fileUploadCount = 0

    const fileUploads = files.map((file) => {
      const request = new XMLHttpRequest()
      const fileUpload = new FileUpload(file, request)

      if (Alchemy.uploader_defaults.upload_limit - 1 < fileUploadCount) {
        fileUpload.valid = false
        fileUpload.errorMessage = translate("Maximum number of files exceeded")
      } else if (fileUpload.valid) {
        fileUploadCount++
        this._submitFile(request, file)
      }

      return fileUpload
    })

    // create progress bar
    this.uploadProgress = new Progress(fileUploads)
    this.uploadProgress.onComplete = (status) => {
      if (status === "successful") {
        // wait three seconds to see the result of the progressbar
        setTimeout(() => (this.uploadProgress.visible = false), 1500)
        setTimeout(() => this.dispatchCustomEvent("Upload.Complete"), 2000)
      } else {
        this.dispatchCustomEvent("Upload.Failure")
      }
    }

    document.body.append(this.uploadProgress)
  }

  /**
   * @param {XMLHttpRequest} request
   * @param {File} file
   * @private
   */
  _submitFile(request, file) {
    const form = this.querySelector("form")
    const formData = new FormData(form)
    formData.set(this.fileInput.name, file)
    request.open("POST", form.action)
    request.setRequestHeader("X-CSRF-Token", getToken())
    request.setRequestHeader("X-Requested-With", "XMLHttpRequest")
    request.setRequestHeader("Accept", "application/json")
    request.send(formData)
  }

  /**
   * @returns {HTMLInputElement}
   */
  get fileInput() {
    return this.querySelector("input[type='file']")
  }
}

customElements.define("alchemy-uploader", Uploader)
