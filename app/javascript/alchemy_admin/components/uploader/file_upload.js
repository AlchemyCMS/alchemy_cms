import { formatFileSize } from "alchemy_admin/utils/format"
import { translate } from "alchemy_admin/i18n"
import { growl } from "alchemy_admin/growler"

export class FileUpload extends HTMLElement {
  // public — used by callers (Uploader, Progress, tests)
  file = null
  request = null
  progressEventLoaded = 0
  progressEventTotal = 0

  // private — backing state for getters/setters
  #valid = true
  #value = 0
  #status = undefined
  #errorMessage = ""

  connectedCallback() {
    this.innerHTML = `
      <sl-progress-bar value="${this.value}"></sl-progress-bar>
      <div class="description">
        <span class="file-name">${this.file?.name}</span>
        <span class="loaded-size">${this.loadedSize}</span>
        <span class="error-message">${this.errorMessage}</span>
      </div>
      <sl-tooltip content="${translate("Abort upload")}">
        <button class="icon_button" aria-label="${translate("Abort upload")}">
          <alchemy-icon name="close"></alchemy-icon>
        </button>
      </sl-tooltip>
    `

    this.querySelector("button").addEventListener("click", () => this.cancel())

    if (this.file?.type.includes("image")) {
      const reader = new FileReader()
      reader.readAsDataURL(this.file)
      reader.addEventListener("load", () => {
        const image = new Image()
        image.src = reader.result
        this.prepend(image)
      })
    }
  }

  /**
   * Initialize the component with file and request
   * @param {File} file
   * @param {XMLHttpRequest} request
   */
  initialize(file, request) {
    this.file = file
    this.request = request
    this.progressEventTotal = file ? file.size : 0
    this.status = "in-progress"

    this.#validateFile()
    this.#addRequestEventListener()
  }

  /**
   * cancel the upload
   */
  cancel() {
    if (!this.finished) {
      this.status = "canceled"
      this.request?.abort()
      this.dispatchCustomEvent("FileUpload.Change")
    }
  }

  /**
   * Dispatches a custom event with given name, namespaced under `Alchemy.`.
   * @param {string} name The name of the custom event
   */
  dispatchCustomEvent(name) {
    this.dispatchEvent(new CustomEvent(`Alchemy.${name}`, { bubbles: true }))
  }

  /**
   * validate given file with the `Alchemy.uploader_defaults` - configuration
   */
  #validateFile() {
    const config = Alchemy.uploader_defaults
    const maxFileSize = config.file_size_limit * Math.pow(1024, 2) // in Byte
    let errorMessage = undefined

    if (this.file?.size > maxFileSize) {
      errorMessage = translate("Uploaded bytes exceed file size")
    }

    const allowedFiletypes = this.file?.type.includes("image")
      ? config.allowed_filetypes.alchemy_pictures
      : config.allowed_filetypes.alchemy_attachments

    const isFileFormatSupported =
      allowedFiletypes.includes("*") ||
      allowedFiletypes.includes(
        this.file?.type.replace(/^\w+\/(\w+)(\+\w+)?/i, "$1")
      )

    if (!isFileFormatSupported) {
      errorMessage = translate("File type not allowed")
    }

    if (errorMessage) {
      this.valid = false
      this.errorMessage = errorMessage
    }
  }

  /**
   * register event listeners to react on request changes
   */
  #addRequestEventListener() {
    // prevent errors if the component will be called without a request - object
    if (!this.request) {
      return
    }

    // update the progress bar and currently loaded size information
    this.request.upload.onprogress = (progressEvent) => {
      this.progressEvent = progressEvent
    }

    // triggers, when the upload is done
    this.request.onload = () => {
      if (this.request.status < 400) {
        this.status = "successful"
        growl(this.responseMessage)
      } else {
        this.status = "failed"
        this.errorMessage = this.responseMessage
      }
      this.dispatchCustomEvent("FileUpload.Change")
    }

    // catch request errors
    this.request.onerror = () => {
      this.errorMessage = translate("An error occurred during the transaction")
    }
  }

  /**
   * @returns {boolean}
   */
  get active() {
    return this.valid && this.status !== "canceled"
  }

  /**
   * @returns {string}
   */
  get errorMessage() {
    return this.#errorMessage || ""
  }

  /**
   * @param {string} message
   */
  set errorMessage(message) {
    this.#errorMessage = message
    const errorMessageContainer = this.querySelector(".error-message")
    if (errorMessageContainer) {
      errorMessageContainer.textContent = message
    }
    growl(message, "error")
  }

  /**
   * @returns {boolean}
   */
  get finished() {
    return ["canceled", "successful", "failed"].includes(this.status)
  }

  /**
   * format the loaded and total size and present that as a string
   * @returns {string}
   */
  get loadedSize() {
    return `${formatFileSize(this.progressEventLoaded)} / ${formatFileSize(
      this.progressEventTotal
    )}`
  }

  /**
   * @returns {HTMLProgressElement|undefined}
   */
  get progressElement() {
    return this.querySelector("sl-progress-bar")
  }

  /**
   * @param {ProgressEvent} progressEvent
   */
  set progressEvent(progressEvent) {
    this.progressEventLoaded = progressEvent.loaded
    this.progressEventTotal = progressEvent.total

    this.value = Math.round((progressEvent.loaded / progressEvent.total) * 100)
    this.querySelector(".loaded-size").textContent = this.loadedSize
  }

  /**
   * @returns {string}
   */
  get responseMessage() {
    try {
      const response = JSON.parse(this.request.responseText)
      return response["message"]
    } catch (error) {
      return `${this.request.status}: ${this.request.statusText}`
    }
  }

  /**
   * @returns {string}
   */
  get status() {
    return this.#status
  }

  /**
   * @param {string} status
   */
  set status(status) {
    this.#status = status
    this.className = status

    this.progressElement?.toggleAttribute(
      "indeterminate",
      status === "upload-finished"
    )
  }

  /**
   * @returns {boolean}
   */
  get valid() {
    return this.#valid
  }

  /**
   * @param {boolean} isValid
   */
  set valid(isValid) {
    this.#valid = isValid
    this.classList.toggle("invalid", !isValid)
  }

  /**
   * get the progress value of the current file
   * @returns {number}
   */
  get value() {
    return this.#value
  }

  /**
   * @param {number} value
   */
  set value(value) {
    this.#value = value
    if (this.progressElement) {
      this.progressElement.value = value
    }

    if (value === 100) {
      this.status = "upload-finished"
    }

    this.dispatchCustomEvent("FileUpload.Change")
  }
}

customElements.define("alchemy-file-upload", FileUpload)
