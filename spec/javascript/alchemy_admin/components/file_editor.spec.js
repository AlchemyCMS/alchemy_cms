import { vi, describe, it, expect } from "vitest"
import "alchemy_admin/components/file_editor"

let elementEditor

function renderComponent() {
  document.body.innerHTML = `
    <alchemy-element-editor>
      <alchemy-file-editor class="ingredient-editor file">
        <div class="file_icon">
          <svg></svg>
        </div>
        <div class="file_name">
          A File.pdf
        </div>
        <a class="remove_file_link" data-form-field-id="file_ingredient_23" href="#">
          <svg></svg>
        </a>
        <div class="file_tools">
          <a class="file_icon" href="/admin/attachments">
            <svg></svg>
          </a>
          <a class="file_icon" href="/admin/ingredients/1/edit">
            <svg></svg>
          </a>
        </div>
        <input type="hidden" id="file_ingredient_23" value="42" />
      </alchemy-file-editor>
    </alchemy-element-editor>
  `
  // Mock the element-editor's setDirty method
  elementEditor = document.querySelector("alchemy-element-editor")
  elementEditor.setDirty = vi.fn()

  return document.querySelector("alchemy-file-editor")
}

describe("FileEditor", () => {
  describe("removeFile", () => {
    it("clears the attachment name", () => {
      const editor = renderComponent()
      editor.removeFile()

      const thumbnail = editor.querySelector(".file_name")
      expect(thumbnail.innerHTML).toBe("")
    })

    it("clears the attachment icon", () => {
      const editor = renderComponent()
      editor.removeFile()

      const thumbnail = editor.querySelector(".file_icon")
      expect(thumbnail.innerHTML).toBe("")
    })

    it("clears the attachment id field", () => {
      const editor = renderComponent()
      editor.removeFile()

      const pictureIdField = editor.querySelector("#file_ingredient_23")
      expect(pictureIdField.value).toBe("")
    })

    it("marks element editor as dirty", () => {
      const editor = renderComponent()
      editor.removeFile()
      expect(elementEditor.setDirty).toHaveBeenCalled()
    })

    it("is triggered by clicking the delete link", () => {
      const editor = renderComponent()
      const deleteLink = editor.querySelector(".remove_file_link")

      deleteLink.click()

      const pictureIdField = editor.querySelector("#file_ingredient_23")
      expect(pictureIdField.value).toBe("")
    })
  })
})
