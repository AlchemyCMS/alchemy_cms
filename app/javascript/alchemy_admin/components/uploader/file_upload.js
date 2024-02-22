import { AlchemyHTMLElement } from "alchemy_admin/components/alchemy_html_element"
import { formatFileSize } from "alchemy_admin/utils/format"
import { translate } from "alchemy_admin/i18n"

export class FileUpload extends AlchemyHTMLElement {
  /**
   * @param {File} file
   * @param {XMLHttpRequest} request
   */
  constructor(file, request) {
    super({})

    this.file = file
    this.request = request

    this.progressEventLoaded = 0
    this.progressEventTotal = file ? file.size : 0
    this.className = "in-progress"
    this.valid = true
    this.value = 0

    this._validateFile()
    this._addRequestEventListener()
  }

  render() {
    return `
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
  }

  afterRender() {
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
   * validate given file with the `Alchemy.uploader_defaults` - configuration
   * @private
   */
  _validateFile() {
    const config = Alchemy.uploader_defaults
    const maxFileSize = config.file_size_limit * Math.pow(1024, 2) // in Byte
    let errorMessage = undefined

    if (this.file?.size > maxFileSize) {
      errorMessage = translate("Uploaded bytes exceed file size")
    }

    const fileConfiguration = this.file?.type.includes("image")
      ? "allowed_filetype_pictures"
      : "allowed_filetype_attachments"

    const isFileFormatSupported =
      config[fileConfiguration] === "*" ||
      config[fileConfiguration].includes(
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
   * @private
   */
  _addRequestEventListener() {
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
        Alchemy.growl(this.responseMessage)
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
    return this._errorMessage || ""
  }

  /**
   * @param {string} message
   */
  set errorMessage(message) {
    this._errorMessage = message
    const errorMessageContainer = this.querySelector(".error-message")
    if (errorMessageContainer) {
      errorMessageContainer.textContent = message
    }
    Alchemy.growl(message, "error")
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
      return translate("Could not parse JSON result")
    }
  }

  /**
   * @returns {string}
   */
  get status() {
    return this._status
  }

  /**
   * @param {string} status
   */
  set status(status) {
    this._status = status
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
    return this._valid
  }

  /**
   * @param {boolean} isValid
   */
  set valid(isValid) {
    this._valid = isValid
    this.classList.toggle("invalid", !isValid)
  }

  /**
   * get the progress value of the current file
   * @returns {number}
   */
  get value() {
    return this._value
  }

  /**
   * @param {number} value
   */
  set value(value) {
    this._value = value
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
