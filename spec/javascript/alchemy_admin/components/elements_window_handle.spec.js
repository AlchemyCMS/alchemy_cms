import { vi } from "vitest"

import "alchemy_admin/components/elements_window_handle"

function getHandle() {
  return document.querySelector("alchemy-elements-window-handle")
}

describe("alchemy-elements-window-handle", () => {
  let handle
  let elementsWindow
  let previewWindow

  beforeEach(() => {
    // window.innerWidth is 1024 in jsdom, so the dragged width is
    // 1024 - pageX. We give the window CSS bounds of 400px..1000px.
    document.body.innerHTML = `
      <alchemy-elements-window style="min-width: 400px; max-width: 1000px;"></alchemy-elements-window>
      <iframe id="alchemy_preview_window"></iframe>
      <alchemy-elements-window-handle></alchemy-elements-window-handle>
    `
    handle = getHandle()
    elementsWindow = document.querySelector("alchemy-elements-window")
    previewWindow = document.getElementById("alchemy_preview_window")
    elementsWindow.resize = vi.fn()
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  describe("onMouseDown", () => {
    it("marks both windows as dragged", () => {
      handle.onMouseDown()
      expect(elementsWindow.isDragged).toBe(true)
      expect(previewWindow.isDragged).toBe(true)
    })

    it("adds is-dragged class", () => {
      handle.onMouseDown()
      expect(handle.classList.contains("is-dragged")).toBe(true)
    })
  })

  describe("onMouseUp", () => {
    it("unmarks both windows as dragged", () => {
      handle.onMouseDown()
      handle.onMouseUp()
      expect(elementsWindow.isDragged).toBe(false)
      expect(previewWindow.isDragged).toBe(false)
    })

    it("removes is-dragged class", () => {
      handle.onMouseDown()
      handle.onMouseUp()
      expect(handle.classList.contains("is-dragged")).toBe(false)
    })
  })

  describe("onDrag", () => {
    it("resizes to the dragged width when within bounds", () => {
      handle.onMouseDown()
      // 1024 - 424 = 600, within [400, 1000]
      handle.onDrag(424)
      expect(elementsWindow.resize).toHaveBeenCalledWith(600)
    })

    it("clamps to the min width when dragged below it", () => {
      handle.onMouseDown()
      // 1024 - 924 = 100, below min 400
      handle.onDrag(924)
      expect(elementsWindow.resize).toHaveBeenCalledWith(400)
    })

    it("clamps to the max width when dragged above it", () => {
      handle.onMouseDown()
      // 1024 - 0 = 1024, above max 1000
      handle.onDrag(0)
      expect(elementsWindow.resize).toHaveBeenCalledWith(1000)
    })

    it("uses the bounds resolved from the window's computed styles", () => {
      elementsWindow.style.minWidth = "500px"
      elementsWindow.style.maxWidth = "800px"
      handle.onMouseDown()
      handle.onDrag(924) // 100 -> clamped to 500
      expect(elementsWindow.resize).toHaveBeenCalledWith(500)
      handle.onDrag(0) // 1024 -> clamped to 800
      expect(elementsWindow.resize).toHaveBeenCalledWith(800)
    })

    it("falls back to the default max width when none is set", () => {
      elementsWindow.style.maxWidth = "none"
      handle.onMouseDown()
      handle.onDrag(0) // 1024 -> clamped to default max 1000
      expect(elementsWindow.resize).toHaveBeenCalledWith(1000)
    })
  })

  describe("event handling", () => {
    // jsdom ignores pageX passed to the MouseEvent constructor, so set it
    // explicitly on the dispatched event.
    function mouseMove(pageX) {
      const event = new MouseEvent("mousemove")
      Object.defineProperty(event, "pageX", { value: pageX })
      window.dispatchEvent(event)
    }

    it("resizes while dragging on mousemove", () => {
      handle.dispatchEvent(new MouseEvent("mousedown", { bubbles: true }))
      mouseMove(424) // 1024 - 424 = 600
      expect(elementsWindow.resize).toHaveBeenCalledWith(600)
    })

    it("does not resize on mousemove when not dragging", () => {
      mouseMove(424)
      expect(elementsWindow.resize).not.toHaveBeenCalled()
    })

    it("stops dragging on mouseup", () => {
      handle.dispatchEvent(new MouseEvent("mousedown", { bubbles: true }))
      window.dispatchEvent(new MouseEvent("mouseup"))
      mouseMove(424)
      expect(elementsWindow.resize).not.toHaveBeenCalled()
    })
  })
})
