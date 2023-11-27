import mock from "xhr-mock"

import { Progress } from "alchemy_admin/components/uploader/progress"
import { FileUpload } from "alchemy_admin/components/uploader/file_upload"

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

  const mockXMLHttpRequest = (status = 200, response = {}) => {
    mock.setup()
    mock.post("/admin/pictures", {
      status,
      body: JSON.stringify(response)
    })

    let request = new XMLHttpRequest()
    request.abort = jest.fn() // necessary to test abort mechanic

    return request
  }

  /**
   * initialize upload progress component with the correct constructor
   * @param {FileUpload[]} fileUploads
   */
  const renderComponent = (
    fileUploads = [
      new FileUpload(firstFile, mockXMLHttpRequest()),
      new FileUpload(secondFile, mockXMLHttpRequest())
    ]
  ) => {
    component = new Progress(fileUploads)

    document.body.append(component)

    progressBar = document.querySelector("progress")
    overallProgressValue = document.querySelector(".overall-progress-value")
    overallUploadValue = document.querySelector(".overall-upload-value")

    const fileUploadComponents = document.querySelectorAll(
      "alchemy-file-upload"
    )
    firstFileUpload = fileUploadComponents[0]
    secondFileUpload = fileUploadComponents[1]
  }

  const progressEvent = (loaded = 0, total = 100) => {
    return new ProgressEvent("load", { loaded, total })
  }

  beforeAll(() => {
    // ignore missing translation warnings
    global.console = {
      ...console,
      warn: jest.fn()
    }

    Alchemy = {
      growl: jest.fn(),
      uploader_defaults: {
        file_size_limit: 100,
        upload_limit: 50,
        allowed_filetype_pictures: "webp, png, svg",
        allowed_filetype_attachments: "*"
      }
    }
  })

  afterEach(() => {
    mock.teardown()
    document.body.innerHTML = "" // reset previous content to prevent raise conditions
  })

  describe("Initial State", () => {
    beforeEach(renderComponent)

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
  })

  describe("update", () => {
    describe("in progress upload", () => {
      beforeEach(renderComponent)

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
      // beforeEach(() => {
      //   firstFileUpload.request.upload.onprogress(progressEvent(100))
      //   secondFileUpload.request.upload.onprogress(progressEvent(200, 200))
      // })

      it("should marked as upload-finished (the response from the server is missing)", () => {
        renderComponent()
        firstFileUpload.request.upload.onprogress(progressEvent(100))
        secondFileUpload.request.upload.onprogress(progressEvent(200, 200))
        expect(component.status).toEqual("upload-finished")
      })

      it("should marked as successful", () => {
        renderComponent()
        firstFileUpload.request.upload.onprogress(progressEvent(100))
        secondFileUpload.request.upload.onprogress(progressEvent(200, 200))

        firstFileUpload.request.onload()
        secondFileUpload.request.onload()
        expect(component.status).toEqual("successful")
        expect(component.className).toEqual("successful visible")
      })

      it("should set overall progress value", () => {
        renderComponent()
        firstFileUpload.request.upload.onprogress(progressEvent(100))
        secondFileUpload.request.upload.onprogress(progressEvent(200, 200))

        expect(overallProgressValue.textContent).toEqual("100% (2 / 2)")
      })

      it("should marked progress as failed if one upload was not successful", async () => {
        const failedUpload = new FileUpload(secondFile, mockXMLHttpRequest())
        failedUpload.status = "failed"

        renderComponent([
          new FileUpload(firstFile, mockXMLHttpRequest()),
          failedUpload
        ])

        expect(component.status).toEqual("failed")
      })
    })
  })

  describe("finished", () => {
    beforeEach(renderComponent)

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
    beforeEach(renderComponent)

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
    beforeEach(renderComponent)

    it("will be called, if all uploads are finished", () => {
      component.onComplete = jest.fn()
      firstFileUpload.status = "successful"
      secondFileUpload.status = "successful"
      firstFileUpload.dispatchCustomEvent("FileUpload.Change")
      expect(component.onComplete).toHaveBeenCalled()
    })

    it("is not called, before all uploads are finished", () => {
      component.onComplete = jest.fn()
      firstFileUpload.status = "successful"
      firstFileUpload.dispatchCustomEvent("FileUpload.Change")
      expect(component.onComplete).not.toHaveBeenCalled()
    })
  })

  describe("cancel upload", () => {
    beforeEach(renderComponent)

    beforeEach(() => {
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
    beforeEach(renderComponent)

    beforeEach(() => {
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
    it("should reset files based variables", () => {
      renderComponent()
      component = new Progress()
      expect(component.fileCount).toEqual(0)
    })
  })
})
