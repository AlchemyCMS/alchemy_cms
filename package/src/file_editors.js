class FileEditor {
  constructor(container) {
    this.container = container
    this.deleteLink = container.querySelector(".remove_file_link")
    this.fileIcon = container.querySelector(".file_icon")
    this.fileName = container.querySelector(".file_name")
    this.deleteLink.addEventListener("click", this.removeFile.bind(this))
    this.formFieldId = this.deleteLink.dataset.formFieldId
    this.formField = container.querySelector(`#${this.formFieldId}`)
    this.assignFileText = this.deleteLink.dataset.assignFileText
  }

  removeFile(event) {
    event.stopPropagation()
    this.formField.value = ""
    this.fileIcon.innerHTML = ""
    this.fileName.innerHTML = ""
    this.deleteLink.classList.add("hidden")
    Alchemy.setElementDirty(this.container.closest(".element-editor"))
    return false
  }
}

export default function init(selector) {
  document.querySelectorAll(selector).forEach((node) => {
    new FileEditor(node)
  })
}
