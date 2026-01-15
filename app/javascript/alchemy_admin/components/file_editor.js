class FileEditor extends HTMLElement {
  constructor() {
    super()
    this.deleteLink = this.querySelector(".remove_file_link")
    this.fileIcon = this.querySelector(".file_icon")
    this.fileName = this.querySelector(".file_name")
    this.formFieldId = this.deleteLink.dataset.formFieldId
    this.formField = this.querySelector(`#${this.formFieldId}`)
    this.deleteLink.addEventListener("click", this)
  }

  handleEvent(event) {
    if (event.type === "click") this.removeFile()
    event.stopPropagation()
  }

  removeFile() {
    this.formField.value = ""
    this.fileIcon.innerHTML = ""
    this.fileName.innerHTML = ""
    this.deleteLink.classList.add("hidden")
    this.closest("alchemy-element-editor").setDirty(this.formField)
  }
}

customElements.define("alchemy-file-editor", FileEditor)
