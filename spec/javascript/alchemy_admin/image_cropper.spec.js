import { vi } from "vitest"

// Mock cropperjs so we can control the data the cropper reports and spy on
// the calls the ImageCropper makes against it.
const { CropperMock, cropperInstance } = vi.hoisted(() => {
  const cropperInstance = {
    getData: vi.fn(),
    setData: vi.fn(),
    getCanvasData: vi.fn(),
    setCropBoxData: vi.fn(),
    destroy: vi.fn()
  }
  const CropperMock = vi.fn(function () {
    return cropperInstance
  })
  return { CropperMock, cropperInstance }
})

vi.mock("cropperjs", () => ({ default: CropperMock }))

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
      const cropper = new ImageCropper(image, {
        default_box: {},
        ratio: 1,
        crop_from_form_field_id: "crop_from",
        crop_size_form_field_id: "crop_size",
        element_id: "element_id"
      })
      expect(cropper.cropperOptions["data"]).toEqual({
        height: 480,
        width: 1200,
        x: 0,
        y: 423
      })
    })

    it("does not set min crop size", () => {
      const image = new Image()
      const cropper = new ImageCropper(image, {
        default_box: {},
        ratio: 1,
        crop_from_form_field_id: "crop_from",
        crop_size_form_field_id: "crop_size",
        element_id: "element_id"
      })
      expect(cropper.cropperOptions["minCropBoxWidth"]).toBeUndefined()
      expect(cropper.cropperOptions["minCropBoxHeight"]).toBeUndefined()
    })

    it("prevents CORS issues", () => {
      const image = new Image()
      const cropper = new ImageCropper(image, {
        default_box: {},
        ratio: 1,
        crop_from_form_field_id: "crop_from",
        crop_size_form_field_id: "crop_size",
        element_id: "element_id"
      })
      expect(cropper.cropperOptions["checkCrossOrigin"]).toBe(false)
      expect(cropper.cropperOptions["checkOrientation"]).toBe(false)
    })
  })

  describe("with a dialog", () => {
    let dialog
    let handlers
    let elementEditor

    const defaultSettings = {
      default_box: [5, 6, 700, 400],
      ratio: 1,
      crop_from_form_field_id: "crop_from",
      crop_size_form_field_id: "crop_size",
      element_id: "42"
    }

    function buildCropper(settings = defaultSettings) {
      return new ImageCropper(new Image(), settings)
    }

    function cropFromField() {
      return document.getElementById("crop_from")
    }

    function cropSizeField() {
      return document.getElementById("crop_size")
    }

    beforeEach(() => {
      cropperInstance.getData.mockReturnValue({
        x: 10,
        y: 20,
        width: 300,
        height: 150
      })
      cropperInstance.setData.mockReset()
      cropperInstance.setCropBoxData.mockReset()
      // Image displayed at half its natural size, offset 10px down in the canvas.
      cropperInstance.getCanvasData.mockReturnValue({
        left: 0,
        top: 10,
        width: 500,
        naturalWidth: 1000
      })

      document.body.innerHTML = `
        <div data-element-id="42" class="element-editor">
          <input id="crop_from" type="hidden" value="0x423" />
          <input id="crop_size" type="hidden" value="1200x480" />
        </div>
      `
      elementEditor = document.querySelector("[data-element-id='42']")
      elementEditor.setDirty = vi.fn()

      // jQuery-ish dialog stub that records the click handlers bound to its
      // buttons so the tests can invoke them directly.
      handlers = {}
      dialog = {
        options: {},
        close: vi.fn(),
        dialog_body: {
          find: (selector) => ({
            on: (_event, callback) => {
              handlers[selector] = callback
            }
          })
        }
      }
      Alchemy.currentDialog = vi.fn(() => dialog)
    })

    describe("when applying the crop", () => {
      it("writes the current cropper data into the form fields", () => {
        buildCropper()
        handlers['button[type="submit"]']()

        expect(cropperInstance.getData).toHaveBeenCalledWith(true)
        expect(cropFromField().value).toEqual("10x20")
        expect(cropSizeField().value).toEqual("300x150")
      })

      it("dispatches change events on the form fields", () => {
        const cropFromChange = vi.fn()
        const cropSizeChange = vi.fn()
        cropFromField().addEventListener("change", cropFromChange)
        cropSizeField().addEventListener("change", cropSizeChange)

        buildCropper()
        handlers['button[type="submit"]']()

        expect(cropFromChange).toHaveBeenCalled()
        expect(cropSizeChange).toHaveBeenCalled()
      })

      it("marks the element editor as dirty", () => {
        buildCropper()
        handlers['button[type="submit"]']()

        expect(elementEditor.setDirty).toHaveBeenCalled()
      })

      it("closes the dialog", () => {
        buildCropper()
        handlers['button[type="submit"]']()

        expect(dialog.close).toHaveBeenCalled()
      })
    })

    describe("when resetting the crop", () => {
      it("resets the cropper to the default box", () => {
        buildCropper()
        handlers['button[type="reset"]']()

        expect(cropperInstance.setData).toHaveBeenCalledWith({
          x: 5,
          y: 6,
          width: 700,
          height: 400
        })
      })

      it("re-applies the box position in canvas coordinates", () => {
        // setData reverts the position when the default box is at the maximum
        // crop box size, so the position is re-applied via setCropBoxData using
        // the canvas offset (top 10) and scale (width 500 / naturalWidth 1000).
        buildCropper()
        handlers['button[type="reset"]']()

        expect(cropperInstance.setCropBoxData).toHaveBeenCalledWith({
          left: 0 + 5 * 0.5,
          top: 10 + 6 * 0.5
        })
      })

      it("applies the size before re-applying the position", () => {
        const callOrder = []
        cropperInstance.setData.mockImplementation(() =>
          callOrder.push("setData")
        )
        cropperInstance.setCropBoxData.mockImplementation(() =>
          callOrder.push("setCropBoxData")
        )

        buildCropper()
        handlers['button[type="reset"]']()

        expect(callOrder).toEqual(["setData", "setCropBoxData"])
      })

      it("writes the default box into the form fields", () => {
        buildCropper()
        handlers['button[type="reset"]']()

        expect(cropFromField().value).toEqual("5x6")
        expect(cropSizeField().value).toEqual("700x400")
      })

      it("does not close the dialog", () => {
        buildCropper()
        handlers['button[type="reset"]']()

        expect(dialog.close).not.toHaveBeenCalled()
      })
    })
  })
})
