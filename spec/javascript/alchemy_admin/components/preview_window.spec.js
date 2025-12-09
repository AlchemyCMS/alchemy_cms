import "alchemy_admin/components/preview_window"
import * as growler from "alchemy_admin/growler"
import { setupLanguage } from "./component.helper"

describe("alchemy-preview-window", () => {
  /**
   * @type {HTMLIFrameElement | undefined}
   */
  let previewWindow = undefined
  let reloadButton = undefined

  beforeEach(() => {
    document.body.innerHTML = `
      <div id="flash_notices"></div>
      <button id="reload_preview_button">
        <span>Reload</span>
      </button>
      <select id="preview_size"></select>
      <iframe
        is="alchemy-preview-window"
        id="alchemy_preview_window"
        url="about:blank"
      ></iframe>
    `
    previewWindow = document.querySelector('[is="alchemy-preview-window"]')
    reloadButton = document.getElementById("reload_preview_button")
  })

  afterEach(() => {
    document.body.innerHTML = ""
  })

  describe("refresh with timeout", () => {
    let growlSpy

    beforeEach(() => {
      setupLanguage()
      Alchemy.translations["Preview failed to load"] =
        "Preview failed to load. Please try again."
      vi.useFakeTimers()
      growlSpy = vi.spyOn(growler, "growl")
    })

    afterEach(() => {
      vi.restoreAllMocks()
    })

    it("starts spinner when refresh is called", () => {
      const originalContent = reloadButton.innerHTML

      previewWindow.refresh()

      expect(reloadButton.innerHTML).toContain("alchemy-spinner")
      expect(reloadButton.innerHTML).not.toBe(originalContent)
    })

    it("stops spinner when iframe loads successfully", async () => {
      const originalContent = reloadButton.innerHTML

      previewWindow.refresh()
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Simulate iframe load event
      previewWindow.dispatchEvent(new Event("load"))

      expect(reloadButton.innerHTML).toBe(originalContent)
      expect(reloadButton.innerHTML).not.toContain("alchemy-spinner")
    })

    it("stops spinner after 5s timeout if iframe doesn't load", () => {
      const originalContent = reloadButton.innerHTML

      previewWindow.refresh()
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Fast-forward time by 5 seconds
      vi.advanceTimersByTime(5000)

      expect(reloadButton.innerHTML).toBe(originalContent)
      expect(reloadButton.innerHTML).not.toContain("alchemy-spinner")
      expect(growlSpy).toHaveBeenCalledWith(
        "Preview failed to load. Please try again.",
        "warning"
      )
    })

    it("clears timeout when iframe loads before timeout expires", () => {
      const originalContent = reloadButton.innerHTML

      previewWindow.refresh()
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Fast-forward time by 2 seconds (less than timeout)
      vi.advanceTimersByTime(2000)
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Simulate iframe load event
      previewWindow.dispatchEvent(new Event("load"))
      expect(reloadButton.innerHTML).toBe(originalContent)

      // Fast-forward remaining time - spinner should stay stopped
      vi.advanceTimersByTime(3000)
      expect(reloadButton.innerHTML).toBe(originalContent)
      expect(reloadButton.innerHTML).not.toContain("alchemy-spinner")
      // Growl should NOT be called since iframe loaded successfully
      expect(growlSpy).not.toHaveBeenCalled()
    })

    it("clears previous timeout when refresh is called again", () => {
      previewWindow.refresh()
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Fast-forward 2 seconds
      vi.advanceTimersByTime(2000)

      // Call refresh again before timeout
      previewWindow.refresh()
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Fast-forward 4 seconds (total 6s from first refresh, but only 4s from second)
      vi.advanceTimersByTime(4000)

      // Spinner should still be showing because new 5s timeout hasn't expired
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Fast-forward 1 more second to complete new timeout
      vi.advanceTimersByTime(1000)
      expect(reloadButton.innerHTML).not.toContain("alchemy-spinner")
    })

    it("allows reload button to be clicked again after timeout", () => {
      const originalContent = reloadButton.innerHTML

      // First refresh
      previewWindow.refresh()
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Wait for timeout
      vi.advanceTimersByTime(5000)
      expect(reloadButton.innerHTML).toBe(originalContent)

      // Click reload button again
      reloadButton.click()
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Verify it works again
      vi.advanceTimersByTime(5000)
      expect(reloadButton.innerHTML).toBe(originalContent)
    })

    it("stops spinner when receiving previewReady message from iframe", () => {
      const originalContent = reloadButton.innerHTML

      previewWindow.refresh()
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Fast-forward 2 seconds (less than timeout)
      vi.advanceTimersByTime(2000)
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Simulate postMessage from iframe
      window.dispatchEvent(
        new MessageEvent("message", {
          data: { message: "Alchemy.previewReady" }
        })
      )

      expect(reloadButton.innerHTML).toBe(originalContent)
      expect(reloadButton.innerHTML).not.toContain("alchemy-spinner")

      // Fast-forward remaining time - spinner should stay stopped and no growl
      vi.advanceTimersByTime(3000)
      expect(reloadButton.innerHTML).toBe(originalContent)
      expect(growlSpy).not.toHaveBeenCalled()
    })

    it("prefers postMessage over timeout when both occur", () => {
      const originalContent = reloadButton.innerHTML

      previewWindow.refresh()
      expect(reloadButton.innerHTML).toContain("alchemy-spinner")

      // Simulate postMessage from iframe before timeout
      window.dispatchEvent(
        new MessageEvent("message", {
          data: { message: "Alchemy.previewReady" }
        })
      )

      expect(reloadButton.innerHTML).toBe(originalContent)

      // Fast-forward past timeout - nothing should happen, already stopped
      vi.advanceTimersByTime(5000)
      expect(reloadButton.innerHTML).toBe(originalContent)
      expect(growlSpy).not.toHaveBeenCalled()
    })
  })
})
