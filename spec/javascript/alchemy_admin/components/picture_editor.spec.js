import { vi, describe, it, expect } from "vitest"
import "alchemy_admin/components/picture_editor"

vi.mock("alchemy_admin/image_loader", () => ({
  __esModule: true,
  default: vi.fn().mockImplementation(() => ({
    load: vi.fn()
  }))
}))

function renderComponent(options = {}) {
  const {
    pictureId = "1",
    targetSize = "1200x480",
    imageCropper = "true",
    imageFileWidth = "5644",
    imageFileHeight = "3761",
    cropFrom = "0x423",
    cropSize = "5644x2258",
    cropLinkHref = "/admin/pictures/1/crop?picture_id=1"
  } = options

  document.body.innerHTML = `
    <div class="element-editor">
    <alchemy-picture-editor class="ingredient-editor picture">
      <div
        data-target-size="${targetSize}"
        data-image-cropper="${imageCropper}"
        class="picture_thumbnail"
      >
        <button type="button" class="picture_tool delete"></button>
        <div class="picture_image">
          <alchemy-picture-thumbnail>
            <div class="thumbnail_background">
              <img src="/image.jpg" />
            </div>
          </alchemy-picture-thumbnail>
        </div>
        <div class="edit_images_bottom">
          <a class="crop_link" href="${cropLinkHref}">Crop</a>
        </div>
      </div>
      <input
        value="${pictureId}"
        data-picture-id="true"
        data-image-file-width="${imageFileWidth}"
        data-image-file-height="${imageFileHeight}"
        type="hidden"
      />
      <input data-link-value="true" type="hidden" value="" />
      <input data-link-title="true" type="hidden" value="" />
      <input data-link-class="true" type="hidden" value="" />
      <input data-link-target="true" type="hidden" value="" />
      <input data-crop-from="true" type="hidden" value="${cropFrom}" />
      <input data-crop-size="true" type="hidden" value="${cropSize}" />
    </alchemy-picture-editor>
    </div>
  `

  // Mock the element-editor's setDirty method
  document.querySelector(".element-editor").setDirty = vi.fn()

  return document.querySelector("alchemy-picture-editor")
}

describe("PictureEditor", () => {
  describe("removeImage", () => {
    it("clears the picture thumbnail", () => {
      const editor = renderComponent()
      editor.removeImage()

      const thumbnail = editor.querySelector("alchemy-picture-thumbnail")
      expect(thumbnail.innerHTML).toContain("alchemy-icon")
    })

    it("clears the picture id field", () => {
      const editor = renderComponent()
      editor.removeImage()

      const pictureIdField = editor.querySelector("[data-picture-id]")
      expect(pictureIdField.value).toBe("")
    })

    it("disables the crop link", () => {
      const editor = renderComponent()
      editor.removeImage()

      const cropLink = editor.querySelector(".crop_link")
      expect(cropLink.classList.contains("disabled")).toBe(true)
    })

    it("is triggered by clicking the delete button", () => {
      const editor = renderComponent()
      const deleteButton = editor.querySelector(".picture_tool.delete")

      deleteButton.click()

      const pictureIdField = editor.querySelector("[data-picture-id]")
      expect(pictureIdField.value).toBe("")
    })
  })

  describe("defaultCropSize", () => {
    describe("when image cropper is enabled", () => {
      it("calculates crop size based on target size and image dimensions", () => {
        const editor = renderComponent({ imageCropper: "true" })
        expect(editor.defaultCropSize).toEqual([5644, 2258])
      })
    })

    describe("when image cropper is disabled", () => {
      it("is empty", () => {
        const editor = renderComponent({ imageCropper: "false" })
        expect(editor.defaultCropSize).toEqual([])
      })
    })
  })

  describe("defaultCropFrom", () => {
    describe("when image cropper is enabled", () => {
      it("calculates centered crop position", () => {
        const editor = renderComponent({ imageCropper: "true" })
        // defaultCropFrom centers the crop area:
        // x = (imageWidth - cropWidth) / 2 = (5644 - 5644) / 2 = 0
        // y = (imageHeight - cropHeight) / 2 = (3761 - 2258) / 2 = 752 (rounded)
        expect(editor.defaultCropFrom).toEqual([0, 752])
      })
    })

    describe("when image cropper is disabled", () => {
      it("is empty", () => {
        const editor = renderComponent({ imageCropper: "false" })
        expect(editor.defaultCropFrom).toEqual([])
      })
    })
  })

  describe("cropFrom", () => {
    it("returns the field value when set", () => {
      const editor = renderComponent({ cropFrom: "100x200" })
      expect(editor.cropFrom).toBe("100x200")
    })

    it("returns default crop from when field is empty", () => {
      const editor = renderComponent({ cropFrom: "", imageCropper: "true" })
      expect(editor.cropFrom).toBe("0x752")
    })
  })

  describe("cropSize", () => {
    it("returns the field value when set", () => {
      const editor = renderComponent({ cropSize: "800x600" })
      expect(editor.cropSize).toBe("800x600")
    })

    it("returns default crop size when field is empty", () => {
      const editor = renderComponent({ cropSize: "", imageCropper: "true" })
      expect(editor.cropSize).toBe("5644x2258")
    })
  })

  describe("updateCropLink", () => {
    it("removes disabled class from crop link", () => {
      const editor = renderComponent()
      const cropLink = editor.querySelector(".crop_link")
      cropLink.classList.add("disabled")

      editor.updateCropLink()

      expect(cropLink.classList.contains("disabled")).toBe(false)
    })

    it("updates picture_id in existing href", () => {
      const editor = renderComponent({
        pictureId: "42",
        cropLinkHref: "/admin/pictures/1/crop?picture_id=1"
      })

      editor.updateCropLink()

      const cropLink = editor.querySelector(".crop_link")
      expect(cropLink.href).toContain("picture_id=42")
    })

    it("appends picture_id when not in href", () => {
      const editor = renderComponent({
        pictureId: "42",
        cropLinkHref: "/admin/pictures/1/crop?other=param"
      })

      editor.updateCropLink()

      const cropLink = editor.querySelector(".crop_link")
      expect(cropLink.href).toContain("&picture_id=42")
    })

    it("does nothing when picture id is empty", () => {
      const editor = renderComponent({
        pictureId: "",
        cropLinkHref: "/admin/pictures/1/crop?picture_id=1"
      })

      editor.updateCropLink()

      const cropLink = editor.querySelector(".crop_link")
      expect(cropLink.href).toContain("picture_id=1")
    })

    it("does nothing when image cropper is disabled", () => {
      const editor = renderComponent({
        imageCropper: "false",
        cropLinkHref: "/admin/pictures/1/crop?picture_id=1"
      })
      const cropLink = editor.querySelector(".crop_link")
      cropLink.classList.add("disabled")

      editor.updateCropLink()

      expect(cropLink.classList.contains("disabled")).toBe(true)
    })
  })

  describe("mutationCallback", () => {
    it("clears crop fields when picture id changes", () => {
      const editor = renderComponent({
        cropFrom: "100x200",
        cropSize: "800x600"
      })
      const pictureIdField = editor.querySelector("[data-picture-id]")

      // Simulate mutation with pictureId in dataset
      editor.mutationCallback([
        {
          target: pictureIdField
        }
      ])

      const cropFromField = editor.querySelector("[data-crop-from]")
      const cropSizeField = editor.querySelector("[data-crop-size]")
      expect(cropFromField.value).toBe("")
      expect(cropSizeField.value).toBe("")
    })
  })

  describe("imageCropperEnabled", () => {
    it("returns true when data-image-cropper is 'true'", () => {
      const editor = renderComponent({ imageCropper: "true" })
      expect(editor.imageCropperEnabled).toBe(true)
    })

    it("returns false when data-image-cropper is 'false'", () => {
      const editor = renderComponent({ imageCropper: "false" })
      expect(editor.imageCropperEnabled).toBe(false)
    })
  })

  describe("imageFileWidth and imageFileHeight", () => {
    it("returns the image dimensions from data attributes", () => {
      const editor = renderComponent({
        imageFileWidth: "1920",
        imageFileHeight: "1080"
      })
      expect(editor.imageFileWidth).toBe(1920)
      expect(editor.imageFileHeight).toBe(1080)
    })
  })
})
