import "alchemy_admin/components/picture_thumbnail"
import { renderComponent } from "./component.helper"
import { vi } from "vitest"

describe("alchemy-picture-thumbnail", () => {
  describe("constructor", () => {
    it("adds thumbnail_background class", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )

      expect(element.classList).toContain("thumbnail_background")
    })

    it("creates spinner instance", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )

      expect(element.spinner).toBeDefined()
    })

    it("creates image when src attribute is present", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )

      expect(element.image).toBeDefined()
      expect(element.image.src).toBe("https://example.com/image.jpg")
    })

    it("does not create image when src attribute is missing", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )

      expect(element.image).toBeUndefined()
    })
  })

  describe("connectedCallback", () => {
    it("shows spinner and appends image while loading", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )

      expect(element.querySelector("alchemy-spinner")).not.toBeNull()
      expect(element).toContain(element.image)
    })

    it("appends image when already complete", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      element.image = new Image()
      Object.defineProperty(element.image, "complete", { value: true })

      element.connectedCallback()

      expect(element).toContain(element.image)
    })

    it("replaces placeholder content with spinner and image while loading", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"><alchemy-icon name="image"></alchemy-icon></alchemy-picture-thumbnail>'
      )

      expect(element.querySelector("alchemy-icon")).toBeNull()
      expect(element.querySelector("alchemy-spinner")).not.toBeNull()
      expect(element).toContain(element.image)
    })

    it("does nothing if image does not exist", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )

      expect(element.childNodes.length).toBe(0)
    })
  })

  describe("disconnectedCallback", () => {
    it("removes event listeners", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      const removeListenerSpy = vi.spyOn(element.image, "removeEventListener")
      element.remove()

      expect(removeListenerSpy).toHaveBeenCalledWith("load", element)
      expect(removeListenerSpy).toHaveBeenCalledWith("error", element)
    })

    it("calls stop", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      const stopSpy = vi.spyOn(element, "stop")
      element.remove()

      expect(stopSpy).toHaveBeenCalled()
    })

    it("does not throw if image does not exist", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )

      expect(() => element.remove()).not.toThrow()
    })
  })

  describe("createImage", () => {
    it("creates image with src", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      element.createImage("https://example.com/test.jpg")

      expect(element.image.src).toBe("https://example.com/test.jpg")
    })

    it("creates image with alt text if name given", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      element.createImage("https://example.com/test.jpg", "Test image")

      expect(element.image.alt).toBe("Test image")
    })

    it("creates image without alt text if name not given", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      element.createImage("https://example.com/test.jpg")

      expect(element.image.alt).not.toBe("Test image")
    })

    it("sets loading to lazy", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      element.createImage("https://example.com/test.jpg")

      expect(element.image.loading).toBe("lazy")
    })

    it("uses default src from attribute", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/default.jpg"></alchemy-picture-thumbnail>'
      )
      element.createImage()

      expect(element.image.src).toBe("https://example.com/default.jpg")
    })
  })

  describe("load", () => {
    it("sets loading attribute", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      element.load()

      expect(element.hasAttribute("loading")).toBe(true)
    })

    it("clears innerHTML", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      element.innerHTML = "<div>some content</div>"
      element.load()

      expect(element.innerHTML).not.toContain("some content")
    })

    it("starts spinner", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      const spinSpy = vi.spyOn(element.spinner, "spin")
      element.load()

      expect(spinSpy).toHaveBeenCalledWith(element)
    })

    it("does not load if image is already complete", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      // Mock image as complete
      vi.spyOn(element.image, "complete", "get").mockReturnValue(true)
      const spinSpy = vi.spyOn(element.spinner, "spin")

      element.load()

      expect(spinSpy).not.toHaveBeenCalled()
    })

    it("does nothing if no image exists", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      element.image = null

      expect(() => element.load()).not.toThrow()
    })
  })

  describe("stop", () => {
    it("removes loading class", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      element.classList.add("loading")
      element.stop()

      expect(element.classList.contains("loading")).toBe(false)
    })

    it("stops spinner", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      const stopSpy = vi.spyOn(element.spinner, "stop")
      element.stop()

      expect(stopSpy).toHaveBeenCalled()
    })
  })

  describe("handleEvent", () => {
    it("handles load event", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      element.setAttribute("loading", "loading")
      const stopSpy = vi.spyOn(element.spinner, "stop")

      element.handleEvent({ type: "load" })

      expect(stopSpy).toHaveBeenCalled()
      expect(element.hasAttribute("loading")).toBe(false)
      expect(element).toContain(element.image)
    })

    it("handles error event", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      const consoleErrorSpy = vi
        .spyOn(console, "error")
        .mockImplementation(() => {})
      const stopSpy = vi.spyOn(element.spinner, "stop")

      element.handleEvent({ type: "error" })

      expect(stopSpy).toHaveBeenCalled()
      expect(element.innerHTML).toContain("alchemy-icon")
      expect(element.innerHTML).toContain("alert")
      expect(consoleErrorSpy).toHaveBeenCalled()

      consoleErrorSpy.mockRestore()
    })

    it("does nothing for unknown event types", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )

      expect(() => element.handleEvent({ type: "unknown" })).not.toThrow()
    })
  })

  describe("loading setter", () => {
    it("calls load when set to true", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      const loadSpy = vi.spyOn(element, "load")

      element.loading = true

      expect(loadSpy).toHaveBeenCalled()
    })

    it("calls stop when set to false", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )
      const stopSpy = vi.spyOn(element, "stop")

      element.loading = false

      expect(stopSpy).toHaveBeenCalled()
    })
  })

  describe("start", () => {
    it("creates image with provided src", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )

      element.start("https://example.com/test.jpg")

      expect(element.image).toBeDefined()
      expect(element.image.src).toBe("https://example.com/test.jpg")
    })

    it("adds load event listener", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      const addListenerSpy = vi.spyOn(
        HTMLImageElement.prototype,
        "addEventListener"
      )

      element.start("https://example.com/test.jpg")

      expect(addListenerSpy).toHaveBeenCalledWith("load", element)

      addListenerSpy.mockRestore()
    })

    it("adds error event listener", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      const addListenerSpy = vi.spyOn(
        HTMLImageElement.prototype,
        "addEventListener"
      )

      element.start("https://example.com/test.jpg")

      expect(addListenerSpy).toHaveBeenCalledWith("error", element)

      addListenerSpy.mockRestore()
    })

    it("calls load", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      const loadSpy = vi.spyOn(element, "load")

      element.start("https://example.com/test.jpg")

      expect(loadSpy).toHaveBeenCalled()
    })
  })

  describe("src setter", () => {
    it("calls start with new src", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      const startSpy = vi.spyOn(element, "start")

      element.src = "https://example.com/new.jpg"

      expect(startSpy).toHaveBeenCalledWith("https://example.com/new.jpg")
    })

    it("shows spinner while new image is loading", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/old.jpg"></alchemy-picture-thumbnail>'
      )
      const oldImage = element.image

      element.src = "https://example.com/new.jpg"

      expect(element.contains(oldImage)).toBe(false)
      expect(element.querySelector("alchemy-spinner")).not.toBeNull()
    })

    it("replaces children with image when already complete", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )
      const startSpy = vi.spyOn(element, "start").mockImplementation(() => {
        element.image = new Image()
        Object.defineProperty(element.image, "complete", { value: true })
      })

      element.src = "https://example.com/new.jpg"

      expect(element.contains(element.image)).toBe(true)
      startSpy.mockRestore()
    })
  })

  describe("name getter", () => {
    it("returns name attribute value", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail name="A nice image"></alchemy-picture-thumbnail>'
      )

      expect(element.name).toBe("A nice image")
    })

    it("returns null when no name attribute", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )

      expect(element.name).toBeNull()
    })
  })

  describe("src getter", () => {
    it("returns src attribute value", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        '<alchemy-picture-thumbnail src="https://example.com/image.jpg"></alchemy-picture-thumbnail>'
      )

      expect(element.src).toBe("https://example.com/image.jpg")
    })

    it("returns null when no src attribute", () => {
      const element = renderComponent(
        "alchemy-picture-thumbnail",
        "<alchemy-picture-thumbnail></alchemy-picture-thumbnail>"
      )

      expect(element.src).toBeNull()
    })
  })
})
