import { vi } from "vitest"

// Mock cropperjs so we can control the data the cropper reports and spy on
// the calls the component makes against it.
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

const { currentDialogMock } = vi.hoisted(() => {
  return { currentDialogMock: vi.fn() }
})

vi.mock("alchemy_admin/dialog", () => ({
  currentDialog: currentDialogMock
}))

import "alchemy_admin/components/image_cropper"

describe("alchemy-image-cropper", () => {
  let dialog
  let elementEditor

  function buildCropper({ defaultBox = "[5,6,700,400]", ratio = "1" } = {}) {
    const container = document.createElement("div")
    container.innerHTML = `
      <alchemy-image-cropper
        default-box='${defaultBox}'
        crop-from-field-id="crop_from"
        crop-size-field-id="crop_size"
        element-id="42"
        ${ratio ? `ratio="${ratio}"` : ""}
      >
        <img />
        <form>
          <button type="submit">apply</button>
          <button type="reset">reset</button>
        </form>
      </alchemy-image-cropper>
    `
    const element = container.querySelector("alchemy-image-cropper")
    // Appending runs connectedCallback, which initializes cropperjs.
    document.body.appendChild(element)
    return element
  }

  function cropFromField() {
    return document.getElementById("crop_from")
  }

  function cropSizeField() {
    return document.getElementById("crop_size")
  }

  function submitForm(element) {
    element
      .querySelector("form")
      .dispatchEvent(new Event("submit", { cancelable: true }))
  }

  function resetForm(element) {
    element
      .querySelector("form")
      .dispatchEvent(new Event("reset", { cancelable: true }))
  }

  beforeEach(() => {
    vi.clearAllMocks()
    cropperInstance.getData.mockReturnValue({
      x: 10,
      y: 20,
      width: 300,
      height: 150
    })
    // Image displayed at half its natural size, offset 10px down in the canvas.
    cropperInstance.getCanvasData.mockReturnValue({
      left: 0,
      top: 10,
      width: 500,
      naturalWidth: 1000
    })

    dialog = { close: vi.fn() }
    currentDialogMock.mockReturnValue(dialog)

    document.body.innerHTML = `
      <div data-element-id="42" class="element-editor">
        <input id="crop_from" type="hidden" value="0x423" />
        <input id="crop_size" type="hidden" value="1200x480" />
      </div>
    `
    elementEditor = document.querySelector("[data-element-id='42']")
    elementEditor.setDirty = vi.fn()
  })

  describe("cropperOptions", () => {
    it("sets the initial data from the stored crop", () => {
      const element = buildCropper()

      expect(element.cropperOptions.data).toEqual({
        x: 0,
        y: 423,
        width: 1200,
        height: 480
      })
    })

    it("falls back to the default box without a stored crop", () => {
      cropFromField().value = ""
      cropSizeField().value = ""
      const element = buildCropper()

      expect(element.cropperOptions.data).toEqual({
        x: 5,
        y: 6,
        width: 700,
        height: 400
      })
    })

    it("uses the given aspect ratio", () => {
      const element = buildCropper({ ratio: "1.5" })

      expect(element.cropperOptions.aspectRatio).toEqual(1.5)
    })

    it("uses a free aspect ratio when none is given", () => {
      const element = buildCropper({ ratio: "" })

      expect(element.cropperOptions.aspectRatio).toBeNaN()
    })

    it("prevents CORS issues", () => {
      const element = buildCropper()

      expect(element.cropperOptions.checkCrossOrigin).toBe(false)
      expect(element.cropperOptions.checkOrientation).toBe(false)
    })

    it("initializes cropperjs with the image and options", () => {
      const element = buildCropper()

      expect(CropperMock).toHaveBeenCalledWith(
        element.querySelector("img"),
        element.cropperOptions
      )
    })
  })

  describe("when applying the crop", () => {
    it("writes the current cropper data into the form fields", () => {
      const element = buildCropper()
      submitForm(element)

      expect(cropperInstance.getData).toHaveBeenCalledWith(true)
      expect(cropFromField().value).toEqual("10x20")
      expect(cropSizeField().value).toEqual("300x150")
    })

    it("dispatches change events on the form fields", () => {
      const cropFromChange = vi.fn()
      const cropSizeChange = vi.fn()
      cropFromField().addEventListener("change", cropFromChange)
      cropSizeField().addEventListener("change", cropSizeChange)

      const element = buildCropper()
      submitForm(element)

      expect(cropFromChange).toHaveBeenCalled()
      expect(cropSizeChange).toHaveBeenCalled()
    })

    it("marks the element editor as dirty", () => {
      const element = buildCropper()
      submitForm(element)

      expect(elementEditor.setDirty).toHaveBeenCalled()
    })

    it("closes the dialog", () => {
      const element = buildCropper()
      submitForm(element)

      expect(dialog.close).toHaveBeenCalled()
    })
  })

  describe("when resetting the crop", () => {
    it("resets the cropper to the default box", () => {
      const element = buildCropper()
      resetForm(element)

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
      const element = buildCropper()
      resetForm(element)

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

      const element = buildCropper()
      resetForm(element)

      expect(callOrder).toEqual(["setData", "setCropBoxData"])
    })

    it("writes the default box into the form fields", () => {
      const element = buildCropper()
      resetForm(element)

      expect(cropFromField().value).toEqual("5x6")
      expect(cropSizeField().value).toEqual("700x400")
    })

    it("does not close the dialog", () => {
      const element = buildCropper()
      resetForm(element)

      expect(dialog.close).not.toHaveBeenCalled()
    })
  })

  describe("when removed from the DOM", () => {
    it("destroys the cropper", () => {
      const element = buildCropper()
      element.remove()

      expect(cropperInstance.destroy).toHaveBeenCalled()
    })
  })
})
