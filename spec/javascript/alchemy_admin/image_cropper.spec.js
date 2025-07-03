import { vi } from "vitest"
import ImageCropper from "alchemy_admin/image_cropper"

describe("ImageCropper", () => {
  describe("cropperOptions", () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <div id="element_id">
          <input id="crop_from" type="hidden" value="0x423" />
          <input id="crop_size" type="hidden" value="1200x480" />
        </div>
      `
      Alchemy.currentDialog = vi.fn()
    })

    it("is sets initial data", () => {
      const image = new Image()
      const cropper = new ImageCropper(
        image,
        {},
        1,
        ["crop_from", "crop_size"],
        "element_id"
      )
      expect(cropper.cropperOptions["data"]).toEqual({
        height: 480,
        width: 1200,
        x: 0,
        y: 423
      })
    })

    it("does not set min crop size", () => {
      const image = new Image()
      const cropper = new ImageCropper(
        image,
        {},
        1,
        ["crop_from", "crop_size"],
        "element_id"
      )
      expect(cropper.cropperOptions["minCropBoxWidth"]).toBeUndefined()
      expect(cropper.cropperOptions["minCropBoxHeight"]).toBeUndefined()
    })

    it("prevents CORS issues", () => {
      const image = new Image()
      const cropper = new ImageCropper(
        image,
        {},
        1,
        ["crop_from", "crop_size"],
        "element_id"
      )
      expect(cropper.cropperOptions["checkCrossOrigin"]).toBe(false)
      expect(cropper.cropperOptions["checkOrientation"]).toBe(false)
    })
  })
})
