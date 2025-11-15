import { describe, it, expect, vi, beforeEach, afterEach } from "vitest"
import { growl } from "alchemy_admin/growler"
import "alchemy_admin/components/page_node"

// Mock Spinner
vi.mock("alchemy_admin/spinner", () => ({
  default: vi.fn(function () {
    this.spin = vi.fn()
    this.stop = vi.fn()
  })
}))

// Mock growler
vi.mock("alchemy_admin/growler", () => ({
  growl: vi.fn()
}))

// Add missing Alchemy globals (Alchemy is already set up in setup.js)
Alchemy.routes.fold_admin_page_path = (id) => `/admin/pages/${id}/fold`

// Mock Turbo
global.Turbo = {
  renderStreamMessage: vi.fn()
}

describe("AlchemyPageNode", () => {
  let element
  let container

  beforeEach(() => {
    // Create CSRF token meta tag
    const csrfMeta = document.createElement("meta")
    csrfMeta.name = "csrf-token"
    csrfMeta.content = "test-token"
    document.head.appendChild(csrfMeta)

    // Create container with page node structure
    container = document.createElement("div")
    container.innerHTML = `
      <alchemy-page-node page-id="123">
        <li class="sitemap-item">
          <div class="sitemap_page">
            <div class="sitemap_left_images">
              <button class="page_folder">
                <alchemy-icon name="arrow-down-s"></alchemy-icon>
              </button>
            </div>
            <div class="sitemap_sitename">
              <a href="#" class="sitemap_pagename_link">Test Page</a>
            </div>
          </div>
          <ul id="page_123_children" class="children" data-parent-id="123">
            <!-- children here -->
          </ul>
        </li>
      </alchemy-page-node>
    `
    document.body.appendChild(container)
    element = container.querySelector("alchemy-page-node")

    // Mock fetch
    global.fetch = vi.fn(() =>
      Promise.resolve({
        ok: true,
        status: 200,
        headers: new Headers({ "content-type": "text/vnd.turbo-stream.html" }),
        text: () => Promise.resolve("<turbo-stream>...</turbo-stream>")
      })
    )
  })

  afterEach(() => {
    document.body.removeChild(container)
    const csrfMeta = document.querySelector('meta[name="csrf-token"]')
    if (csrfMeta) {
      document.head.removeChild(csrfMeta)
    }
    vi.clearAllMocks()
  })

  describe("initialization", () => {
    it("sets pageId from attribute", () => {
      expect(element.pageId).toBe("123")
    })

    it("sets folded state from attribute", () => {
      expect(element.folded).toBe(false)
    })

    it("sets up folder click event listener", () => {
      const folderIcon = element.querySelector(".page_folder")
      expect(folderIcon).toBeTruthy()
      expect(element.handleEvent).toBeDefined()
    })
  })

  describe("folder click handling", () => {
    it("prevents default and stops propagation", async () => {
      const folderButton = element.querySelector(".page_folder")
      const event = new MouseEvent("click", { bubbles: true, cancelable: true })
      Object.defineProperty(event, "currentTarget", {
        value: folderButton,
        writable: true
      })
      const preventDefaultSpy = vi.spyOn(event, "preventDefault")
      const stopPropagationSpy = vi.spyOn(event, "stopPropagation")

      await element.handleFolderClick(event)

      expect(preventDefaultSpy).toHaveBeenCalled()
      expect(stopPropagationSpy).toHaveBeenCalled()
    })

    it("makes PATCH request to fold endpoint", async () => {
      const folderButton = element.querySelector(".page_folder")
      const event = new MouseEvent("click")
      Object.defineProperty(event, "currentTarget", {
        value: folderButton,
        writable: true
      })

      await element.handleFolderClick(event)

      expect(global.fetch).toHaveBeenCalledWith(
        "http://localhost:3000/admin/pages/123/fold",
        {
          method: "PATCH",
          headers: {
            "Content-Type": "application/json; charset=utf-8",
            Accept: "text/vnd.turbo-stream.html",
            "X-Requested-With": "XMLHttpRequest",
            "X-CSRF-Token": "test-token"
          }
        }
      )
    })

    it("toggles folded state on successful response", async () => {
      const folderButton = element.querySelector(".page_folder")
      const event = new MouseEvent("click")
      Object.defineProperty(event, "currentTarget", {
        value: folderButton,
        writable: true
      })
      expect(element.folded).toBe(false)

      await element.handleFolderClick(event)

      expect(element.folded).toBe(true)
      expect(element.hasAttribute("folded")).toBe(true)
    })

    it("shows error growl on patch failure", async () => {
      global.fetch.mockRejectedValueOnce(new Error("Network error"))
      const folderButton = element.querySelector(".page_folder")
      const event = new MouseEvent("click")
      Object.defineProperty(event, "currentTarget", {
        value: folderButton,
        writable: true
      })

      await element.handleFolderClick(event)

      expect(growl).toHaveBeenCalledWith("Network error", "error")
    })
  })

  describe("toggleChildren", () => {
    it("adds hidden class when folded", () => {
      element.folded = true
      element.toggleChildren()

      const children = element.querySelector("#page_123_children")
      expect(children.classList.contains("hidden")).toBe(true)
    })

    it("removes hidden class when unfolded", () => {
      element.folded = false
      element.toggleChildren()

      const children = element.querySelector("#page_123_children")
      expect(children.classList.contains("hidden")).toBe(false)
    })
  })

  describe("updateFolderIcon", () => {
    it("sets arrow-right-s icon when folded", () => {
      element.folded = true
      element.updateFolderIcon()

      const icon = element.querySelector(".page_folder alchemy-icon")
      expect(icon.getAttribute("name")).toBe("arrow-right-s")
    })

    it("sets arrow-down-s icon when unfolded", () => {
      element.folded = false
      element.updateFolderIcon()

      const icon = element.querySelector(".page_folder alchemy-icon")
      expect(icon.getAttribute("name")).toBe("arrow-down-s")
    })
  })

  describe("cleanup", () => {
    it("removes event listeners on disconnect", () => {
      const folderIcon = element.querySelector(".page_folder")
      const removeEventListenerSpy = vi.spyOn(folderIcon, "removeEventListener")

      element.disconnectedCallback()

      expect(removeEventListenerSpy).toHaveBeenCalledWith("click", element)
    })
  })
})
