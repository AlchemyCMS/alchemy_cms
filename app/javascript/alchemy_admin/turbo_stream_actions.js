import { Turbo } from "@hotwired/turbo-rails"
import { closeCurrentDialog } from "alchemy_admin/dialog"

// A dialog form submits into the dialog frame, so a redirect would be followed
// inside the dialog and render the target page in it. The server answers a
// successful submission with this action instead: close the dialog, then visit
// the destination the action would have redirected to.
Turbo.StreamActions.dialog_visit = function () {
  const url = this.getAttribute("url")

  if (!closeCurrentDialog(() => Turbo.visit(url))) {
    Turbo.visit(url)
  }
}

// The editors observe their form field for mutations, so it must not be replaced.

Turbo.StreamActions.assign_picture = function () {
  const [formField] = this.targetElements

  if (!formField) return

  formField.value = this.getAttribute("picture-id")
  formField.setAttribute(
    "data-image-file-width",
    this.getAttribute("image-file-width")
  )
  formField.setAttribute(
    "data-image-file-height",
    this.getAttribute("image-file-height")
  )

  closeCurrentDialog(() => {
    formField.closest("alchemy-element-editor")?.setDirty()
  })
}

Turbo.StreamActions.assign_attachment = function () {
  const [formField] = this.targetElements

  if (!formField) return

  const fileEditor = formField.parentElement

  formField.value = this.getAttribute("attachment-id")
  fileEditor.querySelector(":scope > .file_name").textContent =
    this.getAttribute("attachment-name")
  fileEditor
    .querySelector(":scope > .file_icon")
    .replaceChildren(this.templateContent)
  fileEditor
    .querySelector(":scope > .remove_file_link")
    .classList.remove("hidden")

  closeCurrentDialog(() => {
    formField.closest("alchemy-element-editor")?.setDirty(formField)
  })
}
