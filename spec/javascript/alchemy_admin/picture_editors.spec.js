import { PictureEditor } from "alchemy_admin/picture_editors"

jest.mock("alchemy_admin/image_loader", () => ({
  __esModule: true,
  default: jest.fn().mockImplementation(() => ({
    load: jest.fn()
  }))
}))

describe("PictureEditor", () => {
  describe("defaultCropSize", () => {
    describe("when image cropper is enabled", () => {
      beforeEach(() => {
        document.body.innerHTML = `
          <div class="ingredient-editor picture">
            <div
              data-target-size="1200x480"
              data-image-cropper="true"
              class="picture_thumbnail"
            >
              <div class="picture_image">
                <button class="picture_tool delete"></button>
                <div class="thumbnail_background">
                  <img src="/image.jpg" />
                </div>
              </div>
            </div>
            <input
              value="1"
              data-picture-id="true"
              data-image-file-width="5644"
              data-image-file-height="3761"
              type="hidden"
            />
            <input
              data-link-value="true"
              type="hidden"
              value=""
            />
            <input
              data-link-title="true"
              type="hidden"
              value=""
            />
            <input
              data-link-class="true"
              type="hidden"
              value=""
            />
            <input
              data-link-target="true"
              type="hidden"
              value=""
            />
            <input
              data-crop-from="true"
              type="hidden"
              value="0x423"
            />
            <input
              data-crop-size="true"
              type="hidden"
              value="5644x2258"
            />
            <input
              type="hidden"
              value="3"
            />
          </div>
        `
      })

      it("is the image size", () => {
        const container = document.querySelector(".ingredient-editor")
        const editor = new PictureEditor(container)
        expect(editor.defaultCropSize).toEqual([5644, 2258])
      })
    })

    describe("when image cropper is disabled", () => {
      beforeEach(() => {
        document.body.innerHTML = `
          <div class="ingredient-editor picture">
            <div
              data-target-size="1200x480"
              data-image-cropper="false"
              class="picture_thumbnail"
            >
              <div class="picture_image">
                <button class="picture_tool delete"></button>
                <div class="thumbnail_background">
                  <img src="/image.jpg" />
                </div>
              </div>
            </div>
            <input
              value="1"
              data-picture-id="true"
              data-image-file-width="5644"
              data-image-file-height="3761"
              type="hidden"
            />
            <input
              data-link-value="true"
              type="hidden"
              value=""
            />
            <input
              data-link-title="true"
              type="hidden"
              value=""
            />
            <input
              data-link-class="true"
              type="hidden"
              value=""
            />
            <input
              data-link-target="true"
              type="hidden"
              value=""
            />
            <input
              data-crop-from="true"
              type="hidden"
              value="0x423"
            />
            <input
              data-crop-size="true"
              type="hidden"
              value="5644x2258"
            />
            <input
              type="hidden"
              value="3"
            />
          </div>
        `
      })

      it("is empty", () => {
        const container = document.querySelector(".ingredient-editor")
        const editor = new PictureEditor(container)
        expect(editor.defaultCropSize).toEqual([])
      })
    })
  })
})
