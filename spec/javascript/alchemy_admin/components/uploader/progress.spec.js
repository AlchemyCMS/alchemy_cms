import { vi } from "vitest"

import { Progress } from "alchemy_admin/components/uploader/progress"
import { FileUpload } from "alchemy_admin/components/uploader/file_upload"

vi.mock("alchemy_admin/growler", () => {
  return {
    growl: vi.fn()
  }
})

describe("alchemy-upload-progress", () => {
  /**
   * @type {Progress}
   */
  let component = undefined
  const firstFile = new File(["a".repeat(100)], "foo.txt", {
    type: "application/txt"
  })
  const secondFile = new File(["a".repeat(200)], "bar.txt", {
    type: "application/txt"
  })

  let progressBar = undefined
  let overallProgressValue = undefined
  let overallUploadValue = undefined
  let firstFileUpload = undefined
  let secondFileUpload = undefined
  let actionButton = undefined

  const mockXMLHttpRequest = (status = 200, response = {}) => {
    const body = JSON.stringify(response)

    const request = {
      status,
      statusText: "OK",
      responseText: body,
      abort: vi.fn(),
      open: vi.fn(),
      send: vi.fn(),
      upload: {
        onprogress: null
      },
      onload: null,
      onerror: null
    }

    // Simulate the request lifecycle
    request.send = vi.fn(() => {
      // Simulate async behavior but resolve immediately for tests
      if (request.onload) {
        request.onload()
      }
    })

    return request
  }

  /**
   * initialize upload progress component with the correct initialization
   * @param {FileUpload[]} fileUploads
   */
  const renderComponent = (
    fileUploads = [
      (() => {
        const upload1 = new FileUpload()
        upload1.initialize(firstFile, mockXMLHttpRequest())
        return upload1
      })(),
      (() => {
        const upload2 = new FileUpload()
        upload2.initialize(secondFile, mockXMLHttpRequest())
        return upload2
      })()
    ]
  ) => {
    component = new Progress()
    component.initialize(fileUploads)

    document.body.innerHTML = "" // reset previous content to prevent race conditions
    document.body.append(component)

    // Wait for the component to be connected and rendered
    return new Promise((resolve) => {
      // Use setTimeout to ensure the component has been fully rendered
      setTimeout(() => {
        progressBar = component.querySelector("sl-progress-bar")
        overallProgressValue = component.querySelector(
          ".overall-progress-value span"
        )
        actionButton = component.querySelector(".icon_button")
        overallUploadValue = component.querySelector(".overall-upload-value")

        const fileUploadComponents = component.querySelectorAll(
          "alchemy-file-upload"
        )
        firstFileUpload = fileUploadComponents[0]
        secondFileUpload = fileUploadComponents[1]
        resolve()
      }, 0)
    })
  }

  const progressEvent = (loaded = 0, total = 100) => {
    return new ProgressEvent("load", { loaded, total })
  }

  beforeAll(() => {
    // ignore missing translation warnings
    global.console = {
      ...console,
      warn: vi.fn()
    }

    Alchemy = {
      uploader_defaults: {
        file_size_limit: 100,
        upload_limit: 50,
        allowed_filetype_pictures: "webp, png, svg",
        allowed_filetype_attachments: "*"
      }
    }
  })

  afterEach(() => {
    document.body.innerHTML = "" // reset previous content to prevent race conditions
  })

  describe("Initial State", () => {
    beforeEach(async () => {
      await renderComponent()
    })

    it("should render a progress bar", () => {
      expect(progressBar).toBeTruthy()
    })

    it("should render overall progress value", () => {
      expect(overallProgressValue.textContent).toEqual("0% (0 / 2)")
    })

    it("should render overall upload value", () => {
      expect(overallUploadValue.textContent).toEqual("0.00 B / 300.00 B")
    })

    it("shows two file upload - components", () => {
      expect(document.querySelectorAll("alchemy-file-upload").length).toEqual(2)
    })

    it("should have a in-progress - status", () => {
      expect(component.className).toEqual("in-progress visible")
    })

    it("should have a total progress of 0", () => {
      expect(progressBar.value).toEqual(0)
    })

    it("shows have a cancel button", () => {
      expect(actionButton.getAttribute("aria-label")).toEqual(
        "Cancel all uploads"
      )
    })
  })

  describe("update", () => {
    describe("in progress upload", () => {
      beforeEach(async () => {
        await renderComponent()
      })

      it("increase the progress bar", () => {
        firstFileUpload.value = 50
        expect(progressBar.value).toEqual(17) // 0.5 * file size / both file sizes => 0.5 * 100 / 300
      })

      it("should update overall upload value", () => {
        firstFileUpload.request.upload.onprogress(progressEvent(50))
        expect(overallUploadValue.textContent).toEqual("50.00 B / 300.00 B")
      })

      it("should update overall progress value", () => {
        firstFileUpload.request.upload.onprogress(progressEvent(100))
        expect(overallProgressValue.textContent).toEqual("34% (1 / 2)") // the values are rounded up
      })
    })

    describe("complete upload", () => {
      it("should marked as upload-finished (the response from the server is missing)", async () => {
        await renderComponent()
        firstFileUpload.request.upload.onprogress(progressEvent(100))
        secondFileUpload.request.upload.onprogress(progressEvent(200, 200))
        expect(component.status).toEqual("upload-finished")
      })

      it("should marked as successful", async () => {
        await renderComponent()
        firstFileUpload.request.upload.onprogress(progressEvent(100))
        secondFileUpload.request.upload.onprogress(progressEvent(200, 200))

        firstFileUpload.request.onload()
        secondFileUpload.request.onload()
        expect(component.status).toEqual("successful")
        expect(component.className).toEqual("successful")
      })

      it("should set overall progress value", async () => {
        await renderComponent()
        firstFileUpload.request.upload.onprogress(progressEvent(100))
        secondFileUpload.request.upload.onprogress(progressEvent(200, 200))

        expect(overallProgressValue.textContent).toEqual("100% (2 / 2)")
      })

      it("should prevent uploads higher than 100%", async () => {
        await renderComponent()
        firstFileUpload.request.upload.onprogress(progressEvent(100))
        secondFileUpload.request.upload.onprogress(progressEvent(220, 200))

        expect(overallProgressValue.textContent).toEqual("100% (2 / 2)")
      })

      it("should marked progress as failed if one upload was not successful", async () => {
        const failedUpload = new FileUpload()
        failedUpload.initialize(secondFile, mockXMLHttpRequest())
        failedUpload.status = "failed"

        const successfulUpload = new FileUpload()
        successfulUpload.initialize(firstFile, mockXMLHttpRequest())

        await renderComponent([successfulUpload, failedUpload])

        expect(component.status).toEqual("failed")
      })
    })
  })

  describe("finished", () => {
    beforeEach(async () => {
      await renderComponent()
    })

    it("should not be finished if still in progress", () => {
      expect(component.finished).toBeFalsy()
    })

    it("should be finished if all uploads are finished", () => {
      firstFileUpload.status = "successful"
      secondFileUpload.status = "successful"
      expect(component.finished).toBeTruthy()
    })
  })

  describe("visible", () => {
    beforeEach(async () => {
      await renderComponent()
    })

    it("should be visible by default", () => {
      expect(component.visible).toBeTruthy()
      expect(component.classList).toContain("visible")
    })

    it("should remove visible - class if it isn't visible", () => {
      component.visible = false
      expect(component.visible).toBeFalsy()
      expect(component.classList).not.toContain("visible")
    })
  })

  describe("onComplete", () => {
    beforeEach(async () => {
      await renderComponent()
    })

    it("will be called, if all uploads are finished", () => {
      component.onComplete = vi.fn()
      firstFileUpload.status = "successful"
      secondFileUpload.status = "successful"
      firstFileUpload.dispatchCustomEvent("FileUpload.Change")
      expect(component.onComplete).toHaveBeenCalled()
    })

    it("is not called, before all uploads are finished", () => {
      component.onComplete = vi.fn()
      firstFileUpload.status = "successful"
      firstFileUpload.dispatchCustomEvent("FileUpload.Change")
      expect(component.onComplete).not.toHaveBeenCalled()
    })
  })

  describe("Action Button", () => {
    beforeEach(async () => {
      await renderComponent()
    })

    it("it cancel the requests, if the upload is active", () => {
      component.cancel = vi.fn()
      actionButton.click()
      expect(component.cancel).toBeCalled()
    })

    describe("after upload", () => {
      beforeEach(async () => {
        firstFileUpload.status = "successful"
        secondFileUpload.status = "successful"
        firstFileUpload.dispatchCustomEvent("FileUpload.Change")
        component.onComplete = () => {
          component.visible = false
        }
      })

      it("shows a close button", () => {
        expect(actionButton.ariaLabel).toEqual("Close")
      })

      it("it is not visible anymore after click", () => {
        expect(component.visible).toBeTruthy()
        actionButton.click()
        expect(component.visible).toBeFalsy()
      })
    })
  })

  describe("cancel upload", () => {
    beforeEach(async () => {
      await renderComponent()
    })

    beforeEach(async () => {
      firstFileUpload.cancel()
      secondFileUpload.request.upload.onprogress(progressEvent(50, 200))
    })

    it("should ignore the progress of the aborted file", () => {
      expect(progressBar.value).toEqual(25)
    })

    it("should ignore the amount", () => {
      expect(overallProgressValue.textContent).toEqual("25% (0 / 1)")
    })
  })

  describe("file invalid", () => {
    beforeEach(async () => {
      await renderComponent()
    })

    beforeEach(async () => {
      firstFileUpload.valid = false
      secondFileUpload.request.upload.onprogress(progressEvent(50, 200))
    })

    it("should ignore the progress of the aborted file", () => {
      expect(progressBar.value).toEqual(25)
    })

    it("should ignore the amount", () => {
      expect(overallProgressValue.textContent).toEqual("25% (0 / 1)")
    })
  })

  describe("Initialization without arguments", () => {
    it("should reset files based variables", async () => {
      await renderComponent()
      component = new Progress()
      expect(component.fileCount).toEqual(0)
    })
  })

  describe("cancel", () => {
    it("should call the cancel - action file upload", async () => {
      const fileUpload = new FileUpload()
      fileUpload.initialize(firstFile, mockXMLHttpRequest())
      fileUpload.cancel = vi.fn()

      await renderComponent([fileUpload])
      component.cancel()
      expect(fileUpload.cancel).toBeCalled()
    })

    it("should have the status canceled", async () => {
      await renderComponent()
      component.cancel()
      expect(component.status).toEqual("canceled")
    })

    it("should call only active file uploads", async () => {
      const activeFileUpload = new FileUpload()
      activeFileUpload.initialize(firstFile, mockXMLHttpRequest())
      const uploadedFileUpload = new FileUpload()
      uploadedFileUpload.initialize(firstFile, mockXMLHttpRequest())
      activeFileUpload.cancel = vi.fn()
      uploadedFileUpload.cancel = vi.fn()
      uploadedFileUpload.status = "canceled"

      await renderComponent([activeFileUpload, uploadedFileUpload])
      component.cancel()
      expect(activeFileUpload.cancel).toBeCalled()
      expect(uploadedFileUpload.cancel).not.toBeCalled()
    })
  })
})
