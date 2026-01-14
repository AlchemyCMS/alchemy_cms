import { vi } from "vitest"
import { renderComponent } from "./component.helper"

vi.mock("alchemy_admin/components/element_editor", () => {
  return {
    ElementEditor: class MockElementEditor extends HTMLElement {
      focusElement = vi.fn(() => true)
      focusElementPreview = vi.fn()
      collapse = vi.fn()
    }
  }
})

import "alchemy_admin/components/elements_window"
import { ElementEditor } from "alchemy_admin/components/element_editor"

// Register the mocked ElementEditor
customElements.define("alchemy-element-editor", ElementEditor)

function getComponent(html) {
  return renderComponent("alchemy-elements-window", html)
}

describe("alchemy-elements-window", () => {
  let elementsWindow

  const baseHtml = `
    <alchemy-elements-window>
      <button id="collapse-all-elements-button">Collapse All</button>
      <alchemy-element-editor id="element_123"></alchemy-element-editor>
      <alchemy-element-editor id="element_456" compact></alchemy-element-editor>
      <alchemy-element-editor id="element_789" fixed></alchemy-element-editor>
    </alchemy-elements-window>
    <sl-tooltip>
      <button id="element_window_button">
        <alchemy-icon name="menu-unfold"></alchemy-icon>
      </button>
    </sl-tooltip>
    <turbo-frame id="main_content_elements"></turbo-frame>
    <iframe id="alchemy_preview_window"></iframe>
  `

  beforeEach(() => {
    document.body.innerHTML = baseHtml
    document.body.classList.add("elements-window-visible")
    Alchemy = {
      t: vi.fn((key) => key)
    }
    // Clear cookies
    document.cookie =
      "alchemy-elements-window-width=; expires=Thu, 01 Jan 1970 00:00:00 GMT; Path=/;"
    elementsWindow = document.querySelector("alchemy-elements-window")
    // Mock postMessage on the preview window element
    const previewWindow = document.getElementById("alchemy_preview_window")
    previewWindow.postMessage = vi.fn()
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  describe("connectedCallback", () => {
    it("calls resize", () => {
      const resizeSpy = vi.spyOn(elementsWindow.constructor.prototype, "resize")
      getComponent(baseHtml)
      expect(resizeSpy).toHaveBeenCalled()
    })

    describe("with URL hash", () => {
      it("focuses element editor matching hash", () => {
        const originalHash = window.location.hash
        window.location.hash = "#element_123"
        const focusSpy = vi.spyOn(
          elementsWindow.constructor.prototype,
          "focusElementEditor"
        )
        getComponent(baseHtml)
        expect(focusSpy).toHaveBeenCalledWith("#element_123")
        window.location.hash = originalHash
      })
    })

    describe("toggle button click", () => {
      it("toggles elements window", () => {
        const toggleSpy = vi.spyOn(elementsWindow, "toggle")
        const toggleButton = document.querySelector("#element_window_button")
        toggleButton.click()
        expect(toggleSpy).toHaveBeenCalled()
      })

      it("prevents default event behavior", () => {
        const toggleButton = document.querySelector("#element_window_button")
        const event = new Event("click", { cancelable: true })
        const preventDefaultSpy = vi.spyOn(event, "preventDefault")
        toggleButton.dispatchEvent(event)
        expect(preventDefaultSpy).toHaveBeenCalled()
      })
    })
  })

  describe("collapseAllElements", () => {
    it("collapses all non-compact, non-fixed elements", () => {
      const element = document.querySelector("#element_123")
      elementsWindow.collapseAllElements()
      expect(element.collapse).toHaveBeenCalled()
    })

    it("does not collapse compact elements", () => {
      const compactElement = document.querySelector("#element_456")
      elementsWindow.collapseAllElements()
      expect(compactElement.collapse).not.toHaveBeenCalled()
    })

    it("does not collapse fixed elements", () => {
      const fixedElement = document.querySelector("#element_789")
      elementsWindow.collapseAllElements()
      expect(fixedElement.collapse).not.toHaveBeenCalled()
    })
  })

  describe("toggle", () => {
    it("hides when visible", () => {
      const hideSpy = vi.spyOn(elementsWindow, "hide")
      elementsWindow.toggle()
      expect(hideSpy).toHaveBeenCalled()
    })

    it("shows when hidden", () => {
      elementsWindow.hide()
      const showSpy = vi.spyOn(elementsWindow, "show")
      elementsWindow.toggle()
      expect(showSpy).toHaveBeenCalled()
    })
  })

  describe("show", () => {
    beforeEach(() => {
      elementsWindow.hide()
    })

    it("adds elements-window-visible class to body", () => {
      elementsWindow.show()
      expect(document.body.classList.contains("elements-window-visible")).toBe(
        true
      )
    })

    it("updates toggle button tooltip", () => {
      elementsWindow.show()
      expect(Alchemy.t).toHaveBeenCalledWith("Hide elements")
    })

    it("updates toggle button icon to menu-unfold", () => {
      elementsWindow.show()
      const icon = elementsWindow.toggleButton.querySelector("alchemy-icon")
      expect(icon.getAttribute("name")).toBe("menu-unfold")
    })

    it("calls resize", () => {
      const resizeSpy = vi.spyOn(elementsWindow, "resize")
      elementsWindow.show()
      expect(resizeSpy).toHaveBeenCalled()
    })
  })

  describe("hide", () => {
    it("removes elements-window-visible class from body", () => {
      elementsWindow.hide()
      expect(document.body.classList.contains("elements-window-visible")).toBe(
        false
      )
    })

    it("removes --elements-window-width CSS property", () => {
      document.body.style.setProperty("--elements-window-width", "400px")
      elementsWindow.hide()
      expect(
        document.body.style.getPropertyValue("--elements-window-width")
      ).toBe("")
    })

    it("updates toggle button tooltip", () => {
      elementsWindow.hide()
      expect(Alchemy.t).toHaveBeenCalledWith("Show elements")
    })

    it("updates toggle button icon to menu-fold", () => {
      elementsWindow.hide()
      const icon = elementsWindow.toggleButton.querySelector("alchemy-icon")
      expect(icon.getAttribute("name")).toBe("menu-fold")
    })
  })

  describe("resize", () => {
    it("sets CSS property with given width", () => {
      elementsWindow.resize(450)
      expect(
        document.body.style.getPropertyValue("--elements-window-width")
      ).toBe("450px")
    })

    it("sets cookie with given width", () => {
      elementsWindow.resize(450)
      expect(document.cookie).toContain("alchemy-elements-window-width=450")
    })

    it("uses width from cookie if no width given", () => {
      document.cookie = "alchemy-elements-window-width=500; Path=/;"
      elementsWindow.resize()
      expect(
        document.body.style.getPropertyValue("--elements-window-width")
      ).toBe("500px")
    })

    it("does nothing if no width given and no cookie", () => {
      // Clear any existing cookie first
      document.cookie =
        "alchemy-elements-window-width=; expires=Thu, 01 Jan 1970 00:00:00 GMT; Path=/;"
      // Clear any existing width style
      document.body.style.removeProperty("--elements-window-width")
      elementsWindow.resize()
      expect(
        document.body.style.getPropertyValue("--elements-window-width")
      ).toBe("")
    })
  })

  describe("focusElementEditor", () => {
    it("focuses element and preview if element is an ElementEditor", () => {
      const element = document.querySelector("#element_123")
      elementsWindow.focusElementEditor("#element_123")
      expect(element.focusElement).toHaveBeenCalled()
      expect(element.focusElementPreview).toHaveBeenCalled()
    })

    it("does nothing if element is not found", () => {
      elementsWindow.focusElementEditor("#nonexistent")
      // Should not throw
    })

    it("does nothing if element is not an ElementEditor", () => {
      const regularDiv = document.createElement("div")
      regularDiv.id = "regular_div"
      document.body.appendChild(regularDiv)
      elementsWindow.focusElementEditor("#regular_div")
      // Should not throw
    })
  })

  describe("getters", () => {
    describe("collapseButton", () => {
      it("returns the collapse all button", () => {
        expect(elementsWindow.collapseButton).toBe(
          document.querySelector("#collapse-all-elements-button")
        )
      })
    })

    describe("toggleButton", () => {
      it("returns the element window button", () => {
        expect(elementsWindow.toggleButton).toBe(
          document.querySelector("#element_window_button")
        )
      })
    })

    describe("previewWindow", () => {
      it("returns the preview window element", () => {
        expect(elementsWindow.previewWindow).toBe(
          document.getElementById("alchemy_preview_window")
        )
      })
    })

    describe("turboFrame", () => {
      it("returns the closest turbo-frame", () => {
        const html = `
          <turbo-frame id="main_content_elements">
            <alchemy-elements-window></alchemy-elements-window>
          </turbo-frame>
        `
        document.body.innerHTML = html
        elementsWindow = document.querySelector("alchemy-elements-window")
        expect(elementsWindow.turboFrame).toBe(
          document.querySelector("turbo-frame")
        )
      })

      it("caches the turbo-frame reference", () => {
        const html = `
          <turbo-frame id="main_content_elements">
            <alchemy-elements-window></alchemy-elements-window>
          </turbo-frame>
        `
        document.body.innerHTML = html
        elementsWindow = document.querySelector("alchemy-elements-window")
        const frame1 = elementsWindow.turboFrame
        const frame2 = elementsWindow.turboFrame
        expect(frame1).toBe(frame2)
      })
    })

    describe("widthFromCookie", () => {
      it("returns width from cookie", () => {
        document.cookie = "alchemy-elements-window-width=350; Path=/;"
        expect(elementsWindow.widthFromCookie).toBe("350")
      })

      it("returns undefined if cookie not set", () => {
        expect(elementsWindow.widthFromCookie).toBeUndefined()
      })
    })
  })

  describe("isDragged setter", () => {
    beforeEach(() => {
      document.body.innerHTML = `
        <turbo-frame id="main_content_elements">
          <alchemy-elements-window></alchemy-elements-window>
        </turbo-frame>
      `
      elementsWindow = document.querySelector("alchemy-elements-window")
    })

    it("disables transitions when dragging", () => {
      elementsWindow.isDragged = true
      expect(elementsWindow.turboFrame.style.transitionProperty).toBe("none")
    })

    it("disables pointer events when dragging", () => {
      elementsWindow.isDragged = true
      expect(elementsWindow.turboFrame.style.pointerEvents).toBe("none")
    })

    it("restores transitions when not dragging", () => {
      elementsWindow.isDragged = true
      elementsWindow.isDragged = false
      expect(elementsWindow.turboFrame.style.transitionProperty).toBe("")
    })

    it("restores pointer events when not dragging", () => {
      elementsWindow.isDragged = true
      elementsWindow.isDragged = false
      expect(elementsWindow.turboFrame.style.pointerEvents).toBe("")
    })
  })

  describe("event handling", () => {
    describe("collapse button click", () => {
      it("collapses all elements", () => {
        const collapseSpy = vi.spyOn(elementsWindow, "collapseAllElements")
        elementsWindow.collapseButton.click()
        expect(collapseSpy).toHaveBeenCalled()
      })
    })

    describe("message event from window", () => {
      it("shows window and focuses element on Alchemy.focusElementEditor message", () => {
        const showSpy = vi.spyOn(elementsWindow, "show")
        const element = document.querySelector("#element_123")
        window.dispatchEvent(
          new MessageEvent("message", {
            data: { message: "Alchemy.focusElementEditor", element_id: "123" }
          })
        )
        expect(showSpy).toHaveBeenCalled()
        expect(element.focusElement).toHaveBeenCalled()
      })

      it("ignores messages without proper message type", () => {
        const showSpy = vi.spyOn(elementsWindow, "show")
        window.dispatchEvent(
          new MessageEvent("message", {
            data: { message: "SomeOtherMessage", element_id: "123" }
          })
        )
        expect(showSpy).not.toHaveBeenCalled()
      })
    })

    describe("body click", () => {
      it("deselects all element editors when clicking outside", () => {
        const element = document.querySelector("#element_123")
        element.classList.add("selected")
        document.body.click()
        expect(element.classList.contains("selected")).toBe(false)
      })

      it("posts blur message to preview window", () => {
        const previewWindow = document.getElementById("alchemy_preview_window")
        document.body.click()
        expect(previewWindow.postMessage).toHaveBeenCalledWith({
          message: "Alchemy.blurElements"
        })
      })

      it("does not deselect when clicking inside element editor", () => {
        const element = document.querySelector("#element_123")
        element.classList.add("selected")
        element.click()
        expect(element.classList.contains("selected")).toBe(true)
      })
    })
  })
})
