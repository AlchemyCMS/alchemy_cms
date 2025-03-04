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
      Alchemy.currentDialog = jest.fn()
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
