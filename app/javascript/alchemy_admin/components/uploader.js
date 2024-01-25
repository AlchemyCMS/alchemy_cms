/**
 * @typedef {object} PersistedFile
 * @property {string} name
 * @property {number} size
 */
import { AlchemyHTMLElement } from "alchemy_admin/components/alchemy_html_element"
import { Progress } from "alchemy_admin/components/uploader/progress"
import { FileUpload } from "alchemy_admin/components/uploader/file_upload"
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

    this._createProgress(fileUploads)
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
   * create (and maybe remove the old) progress bar - component
   * @param {FileUpload[]} fileUploads
   * @private
   */
  _createProgress(fileUploads) {
    if (this.uploadProgress) {
      this.uploadProgress.cancel()
      document.body.removeChild(this.uploadProgress)
    }
    this.uploadProgress = new Progress(fileUploads)
    this.uploadProgress.onComplete = (status) => {
      this.dispatchCustomEvent(`upload.${status}`)
    }

    document.body.append(this.uploadProgress)
  }

  /**
   * @returns {HTMLInputElement}
   */
  get fileInput() {
    return this.querySelector("input[type='file']")
  }
}

customElements.define("alchemy-uploader", Uploader)
