import { vi } from "vitest"
import { growl } from "alchemy_admin/growler"
import { Uploader } from "alchemy_admin/components/uploader"

vi.mock("alchemy_admin/utils/ajax", () => {
  return {
    __esModule: true,
    getToken: () => "123"
  }
})

vi.mock("alchemy_admin/growler", () => {
  return {
    growl: vi.fn()
  }
})

describe("alchemy-uploader", () => {
  /**
   * @type {Uploader}
   */
  let component = undefined

  const firstFile = new File(["a".repeat(1100)], "foo.txt", {
    type: "application/txt"
  })
  const secondFile = new File(["a".repeat(200)], "bar.txt", {
    type: "application/txt"
  })

  /**
   * @type {HTMLInputElement}
   */
  let input = undefined
  let form = undefined
  let dropzone = undefined

  const renderComponent = () => {
    document.body.innerHTML = `
      <alchemy-uploader>
        <form enctype="multipart/form-data" action="/admin/fake_upload_path">
          <input type="file" multiple name="file-input-name"/>
        </form>
      </alchemy-uploader>
      <div class="dropzone-container"></div>
    `
    component = document.querySelector("alchemy-uploader")
    input = document.querySelector("input")
    form = document.querySelector("form")
    dropzone = document.querySelector(".dropzone-container")
  }

  beforeAll(() => {
    // ignore missing translation warnings
    global.console = {
      ...console,
      warn: vi.fn()
    }
  })

  beforeEach(() => {
    Alchemy = {
      growl: vi.fn(),
      uploader_defaults: {
        file_size_limit: 100,
        upload_limit: 50,
        allowed_filetype_pictures: "webp, png, svg",
        allowed_filetype_attachments: "*"
      }
    }

    renderComponent()

    // Reset the global XMLHttpRequest mock for each test
    vi.clearAllMocks()
  })

  describe("input field", () => {
    it("should call the upload function if the file input changes", () => {
      component._uploadFiles = vi.fn()
      input.dispatchEvent(new CustomEvent("change"))
      expect(component._uploadFiles).toHaveBeenCalledTimes(1)
    })
  })

  describe("_uploadFiles", () => {
    it("should upload files", () => {
      component._uploadFiles([firstFile, secondFile])
      expect(XMLHttpRequest).toHaveBeenCalledTimes(2)
    })

    it("should open the correct url", () => {
      component._uploadFiles([firstFile])
      const mockInstance = XMLHttpRequest.mock.results[0].value
      expect(mockInstance.open).toHaveBeenCalledWith(
        "POST",
        "http://localhost:3000/admin/fake_upload_path"
      )
    })

    it("should send the file form", () => {
      component._uploadFiles([firstFile])
      const mockInstance = XMLHttpRequest.mock.results[0].value
      expect(mockInstance.send).toHaveBeenCalledWith(new FormData(form))
    })
  })

  describe("Upload", () => {
    let progressBar = undefined

    beforeEach(() => {
      component._uploadFiles([firstFile])
      progressBar = document.querySelector(
        "alchemy-upload-progress sl-progress-bar"
      )
    })

    it("shows upload component", () => {
      expect(progressBar).toBeTruthy()
    })

    it("should not have any progress at the beginning", () => {
      expect(progressBar.value).toBe(0)
    })

    it("should not have any progress at the beginning", () => {
      const progress = new ProgressEvent("progress", { loaded: 50, total: 100 })
      const mockInstance = XMLHttpRequest.mock.results[0].value
      mockInstance.upload.onprogress(progress)
      expect(progressBar.value).toBe(50)
    })

    describe("request header", () => {
      it("sends a CSRF token", () => {
        const mockInstance = XMLHttpRequest.mock.results[0].value
        expect(mockInstance.setRequestHeader).toHaveBeenCalledWith(
          "X-CSRF-Token",
          "123"
        )
      })

      it("should mark the request as XHR for Rails request handling", () => {
        const mockInstance = XMLHttpRequest.mock.results[0].value
        expect(mockInstance.setRequestHeader).toHaveBeenCalledWith(
          "X-Requested-With",
          "XMLHttpRequest"
        )
      })

      it("should request json as answer", () => {
        const mockInstance = XMLHttpRequest.mock.results[0].value
        expect(mockInstance.setRequestHeader).toHaveBeenCalledWith(
          "Accept",
          "application/json"
        )
      })
    })

    describe("another upload", () => {
      it("should have only one progress - component", () => {
        component._uploadFiles([firstFile])
        expect(
          document.querySelectorAll("alchemy-upload-progress").length
        ).toEqual(1)
      })

      it("should cancel the previous process", () => {
        const uploadProgress = document.querySelector("alchemy-upload-progress")
        uploadProgress.cancel = vi.fn()
        component._uploadFiles([firstFile])
        expect(uploadProgress.cancel).toBeCalled()
      })
    })
  })

  describe("Validate", () => {
    describe("upload limit", () => {
      beforeEach(() => {
        vi.clearAllMocks() // Clear mocks before this specific test
        Alchemy.uploader_defaults.upload_limit = 2
        component._uploadFiles([firstFile, secondFile, new File([], "foo")])
      })

      it("should upload only two files", () => {
        // XMLHttpRequest is created for all files, but only 2 are actually submitted
        expect(XMLHttpRequest).toHaveBeenCalledTimes(3)
        // Check that only 2 files were actually submitted by checking the mock instances
        const mockInstances = XMLHttpRequest.mock.results.map(
          (result) => result.value
        )
        const submittedFiles = mockInstances.filter(
          (instance) => instance.send.mock.calls.length > 0
        )
        expect(submittedFiles).toHaveLength(2)
      })

      it("should call the growl method", () => {
        expect(growl).toHaveBeenCalledWith(
          "Maximum number of files exceeded",
          "error"
        )
      })

      it("should mark the last file as invalid", () => {
        const progresses = document.querySelectorAll("alchemy-file-upload")

        expect(progresses[0].valid).toBeTruthy()
        expect(progresses[1].valid).toBeTruthy()
        expect(progresses[2].valid).toBeFalsy()
      })
    })
  })

  describe("file not valid", () => {
    beforeEach(() => {
      vi.clearAllMocks() // Clear mocks before this specific test
      Alchemy.uploader_defaults.allowed_filetype_attachments = ["txt"]
      component._uploadFiles([
        new File([], "foo.pdf", { type: "application/pdf" }),
        firstFile,
        secondFile
      ])
    })

    it("should upload only two files", () => {
      // XMLHttpRequest is created for all files, then validation happens
      expect(XMLHttpRequest).toHaveBeenCalledTimes(3)
      // Check that only 2 files were actually submitted (the valid txt files)
      const mockInstances = XMLHttpRequest.mock.results.map(
        (result) => result.value
      )
      const submittedFiles = mockInstances.filter(
        (instance) => instance.send.mock.calls.length > 0
      )
      expect(submittedFiles).toHaveLength(2)
    })

    it("should mark the last file as invalid", () => {
      expect(document.querySelector("alchemy-file-upload").valid).toBeFalsy()
    })
  })

  describe("on complete", () => {
    beforeEach(() => {
      component.dispatchCustomEvent = vi.fn()
      component._uploadFiles([firstFile, secondFile])
    })

    describe("successful", () => {
      beforeEach(() => {
        component.uploadProgress.onComplete("successful")
      })

      it("should fire upload - event", () => {
        expect(component.dispatchCustomEvent).toBeCalledWith(
          "upload.successful"
        )
      })
    })

    describe("canceled", () => {
      beforeEach(() => {
        component.uploadProgress.onComplete("canceled")
      })

      it("should fire upload - event", () => {
        expect(component.dispatchCustomEvent).toBeCalledWith("upload.canceled")
      })
    })

    describe("failed", () => {
      beforeEach(() => {
        component.uploadProgress.onComplete("failed")
      })

      it("should fire upload - event", () => {
        expect(component.dispatchCustomEvent).toBeCalledWith("upload.failed")
      })

      it("should not hide the progress component", () => {
        expect(component.uploadProgress.visible).toBeTruthy()
      })
    })
  })
})
