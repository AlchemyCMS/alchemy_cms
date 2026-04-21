/**
 * @typedef {object} PersistedFile
 * @property {string} name
 * @property {number} size
 */
import { Progress } from "alchemy_admin/components/uploader/progress"
import { FileUpload } from "alchemy_admin/components/uploader/file_upload"
import { translate } from "alchemy_admin/i18n"
import { getToken } from "alchemy_admin/utils/ajax"

export class Uploader extends HTMLElement {
  #dropzoneElement = null
  #isDraggedOver = false

  connectedCallback() {
    this.fileInput.addEventListener("change", this.#onFileInputChange)
    if (this.dropzone) {
      this.#setupDropZone()
    }
    this.addEventListener("Alchemy.upload.successful", this)
  }

  disconnectedCallback() {
    this.fileInput?.removeEventListener("change", this.#onFileInputChange)
    if (this.#dropzoneElement) {
      this.#dropzoneElement.removeEventListener(
        "dragleave",
        this.#onDropzoneDragleave
      )
      this.#dropzoneElement.removeEventListener("drop", this.#onDropzoneDrop)
      this.#dropzoneElement.removeEventListener(
        "dragover",
        this.#onDropzoneDragover
      )
      this.#dropzoneElement = null
    }
  }

  handleEvent(evt) {
    switch (evt.type) {
      case "Alchemy.upload.successful":
        this.#handleUploadComplete()
        break
    }
  }

  #onFileInputChange = (event) => {
    this.uploadFiles(Array.from(event.target.files))
  }

  #toggleDropzoneClass = (enabled) => {
    if (this.#isDraggedOver !== enabled) {
      this.#isDraggedOver = enabled
      this.#dropzoneElement.classList.toggle("dragover")
    }
  }

  #onDropzoneDragleave = () => this.#toggleDropzoneClass(false)

  #onDropzoneDrop = async (event) => {
    event.preventDefault()
    this.#toggleDropzoneClass(false)

    const files = [...event.dataTransfer.items].map((item) => item.getAsFile())

    this.uploadFiles(files)
  }

  #onDropzoneDragover = (event) => {
    event.preventDefault() // dragover has to be disabled to use the custom drop event
    this.#toggleDropzoneClass(true)
  }

  #handleUploadComplete() {
    setTimeout(() => {
      const url = this.redirectUrl
      const turboFrame = this.closest("turbo-frame")
      this.uploadProgress.visible = false

      if (!url) return

      if (turboFrame) {
        turboFrame.setAttribute("src", url)
        turboFrame.reload()
      } else {
        Turbo.visit(url)
      }
    }, 750)
  }

  /**
   * add dragover class to indicate, if the file is draggable
   * @private
   */
  #setupDropZone() {
    this.#dropzoneElement = document.querySelector(this.dropzone)
    if (!this.#dropzoneElement) return

    this.#dropzoneElement.addEventListener(
      "dragleave",
      this.#onDropzoneDragleave
    )
    this.#dropzoneElement.addEventListener("drop", this.#onDropzoneDrop)
    this.#dropzoneElement.addEventListener("dragover", this.#onDropzoneDragover)
  }

  /**
   * @param {File[]} files
   */
  uploadFiles(files) {
    // prepare file progress bars and server request
    let fileUploadCount = 0

    const fileUploads = files.map((file) => {
      const request = new XMLHttpRequest()
      const fileUpload = new FileUpload()
      fileUpload.initialize(file, request)

      if (Alchemy.uploader_defaults.upload_limit - 1 < fileUploadCount) {
        fileUpload.valid = false
        fileUpload.errorMessage = translate("Maximum number of files exceeded")
      } else if (fileUpload.valid) {
        fileUploadCount++
        this.#submitFile(request, file)
      }

      return fileUpload
    })

    this.#createProgress(fileUploads)
  }

  /**
   * @param {XMLHttpRequest} request
   * @param {File} file
   * @private
   */
  #submitFile(request, file) {
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
  #createProgress(fileUploads) {
    if (this.uploadProgress) {
      this.uploadProgress.cancel()
      document.body.removeChild(this.uploadProgress)
    }
    this.uploadProgress = new Progress()
    this.uploadProgress.initialize(fileUploads)
    this.uploadProgress.onComplete = (status) => {
      this.dispatchEvent(
        new CustomEvent(`Alchemy.upload.${status}`, { bubbles: true })
      )
    }

    document.body.append(this.uploadProgress)
  }

  get dropzone() {
    return this.getAttribute("dropzone")
  }

  /**
   * @returns {HTMLInputElement}
   */
  get fileInput() {
    return this.querySelector("input[type='file']")
  }

  get redirectUrl() {
    return this.getAttribute("redirect-url")
  }
}

customElements.define("alchemy-uploader", Uploader)
