import { describe, it, expect, vi, beforeEach, afterEach } from "vitest"
import "alchemy_admin/components/sitemap"

// Mock dependencies
vi.mock("sortablejs", () => ({
  default: vi.fn()
}))

vi.mock("alchemy_admin/utils/ajax", () => ({
  patch: vi.fn()
}))

vi.mock("alchemy_admin/growler", () => ({
  growl: vi.fn()
}))

vi.mock("alchemy_admin/please_wait_overlay", () => ({
  default: vi.fn()
}))

vi.mock("alchemy_admin/i18n", () => ({
  translate: vi.fn((key) => key)
}))

// Add missing Alchemy globals (Alchemy is already set up in setup.js)
Alchemy.routes.move_admin_page_path = (id) => `/admin/pages/${id}/move`

describe("AlchemySitemap", () => {
  let element
  let container
  let searchInput
  let clearButton
  let resultCounter

  beforeEach(() => {
    // Create search controls
    searchInput = document.createElement("input")
    searchInput.className = "search_input_field"
    searchInput.type = "text"

    clearButton = document.createElement("a")
    clearButton.id = "search_field_clear"
    clearButton.href = "#"

    resultCounter = document.createElement("h2")
    resultCounter.id = "page_filter_result"
    resultCounter.style.display = "none"

    document.body.appendChild(searchInput)
    document.body.appendChild(clearButton)
    document.body.appendChild(resultCounter)

    // Create sitemap with page nodes
    container = document.createElement("div")
    container.innerHTML = `
      <alchemy-sitemap>
        <ul id="sitemap" class="list">
          <alchemy-page-node>
            <li class="sitemap-item">
              <div class="sitemap_page" name="Home Page">
                <div class="sitemap_sitename">
                  <a class="sitemap_pagename_link">Home Page</a>
                </div>
              </div>
            </li>
          </alchemy-page-node>
          <alchemy-page-node>
            <li class="sitemap-item">
              <div class="sitemap_page" name="About Us">
                <div class="sitemap_sitename">
                  <a class="sitemap_pagename_link">About Us</a>
                </div>
              </div>
            </li>
          </alchemy-page-node>
          <alchemy-page-node>
            <li class="sitemap-item">
              <div class="sitemap_page" name="Contact">
                <div class="sitemap_sitename">
                  <a class="sitemap_pagename_link">Contact</a>
                </div>
              </div>
            </li>
          </alchemy-page-node>
        </ul>
      </alchemy-sitemap>
    `
    document.body.appendChild(container)
    element = container.querySelector("alchemy-sitemap")

    // Mock scrollIntoView for all sitemap_page elements
    element.querySelectorAll(".sitemap_page").forEach((page) => {
      page.scrollIntoView = vi.fn()
    })
  })

  afterEach(() => {
    document.body.removeChild(searchInput)
    document.body.removeChild(clearButton)
    document.body.removeChild(resultCounter)
    document.body.removeChild(container)
    vi.clearAllMocks()
  })

  describe("initialization", () => {
    it("finds search input element", () => {
      expect(element.searchInput).toBe(searchInput)
    })

    it("finds clear button element", () => {
      expect(element.clearButton).toBe(clearButton)
    })

    it("finds result counter element", () => {
      expect(element.resultCounter).toBe(resultCounter)
    })

    it("sets up search event listeners", () => {
      expect(element.handleEvent).toBeDefined()
    })

    it("sets up sortables", () => {
      expect(element.setupSortables).toBeDefined()
    })
  })

  describe("search functionality", () => {
    it("filters pages based on search term", () => {
      searchInput.value = "home"
      element.handleSearch({ target: searchInput })

      const pages = element.querySelectorAll(".sitemap_page")
      expect(pages[0].classList.contains("highlight")).toBe(true)
      expect(pages[0].classList.contains("no-match")).toBe(false)
      expect(pages[1].classList.contains("no-match")).toBe(true)
      expect(pages[2].classList.contains("no-match")).toBe(true)
    })

    it("is case-insensitive", () => {
      searchInput.value = "ABOUT"
      element.handleSearch({ target: searchInput })

      const pages = element.querySelectorAll(".sitemap_page")
      expect(pages[1].classList.contains("highlight")).toBe(true)
    })

    it("matches partial terms", () => {
      searchInput.value = "con"
      element.handleSearch({ target: searchInput })

      const pages = element.querySelectorAll(".sitemap_page")
      expect(pages[2].classList.contains("highlight")).toBe(true)
    })

    it("clears filter when search is empty", () => {
      // First add some filters
      searchInput.value = "home"
      element.handleSearch({ target: searchInput })

      // Then clear
      searchInput.value = ""
      element.handleSearch({ target: searchInput })

      const pages = element.querySelectorAll(".sitemap_page")
      pages.forEach((page) => {
        expect(page.classList.contains("highlight")).toBe(false)
        expect(page.classList.contains("no-match")).toBe(false)
      })
    })

    it("updates result counter for single match", () => {
      searchInput.value = "home"
      element.handleSearch({ target: searchInput })

      expect(resultCounter.textContent).toBe("1 page_found")
      expect(resultCounter.style.display).toBe("block")
    })

    it("updates result counter for multiple matches", () => {
      searchInput.value = "o"
      element.handleSearch({ target: searchInput })

      expect(resultCounter.textContent).toBe("3 pages_found")
      expect(resultCounter.style.display).toBe("block")
    })

    it("scrolls first match into view", () => {
      const pages = element.querySelectorAll(".sitemap_page")

      searchInput.value = "about"
      element.handleSearch({ target: searchInput })

      expect(pages[1].scrollIntoView).toHaveBeenCalledWith({
        behavior: "smooth",
        block: "center"
      })
    })
  })

  describe("filterPages", () => {
    it("counts matches correctly", () => {
      element.filterPages("o") // matches "Home", "About", "Contact"

      expect(resultCounter.textContent).toBe("3 pages_found")
    })

    it("handles no matches", () => {
      element.filterPages("xyz")

      const pages = element.querySelectorAll(".sitemap_page")
      pages.forEach((page) => {
        expect(page.classList.contains("no-match")).toBe(true)
      })
      expect(resultCounter.style.display).toBe("none")
    })
  })

  describe("clearFilter", () => {
    it("removes all highlight and no-match classes", () => {
      // Add some classes
      const pages = element.querySelectorAll(".sitemap_page")
      pages[0].classList.add("highlight")
      pages[1].classList.add("no-match")

      element.clearFilter()

      pages.forEach((page) => {
        expect(page.classList.contains("highlight")).toBe(false)
        expect(page.classList.contains("no-match")).toBe(false)
      })
    })

    it("hides result counter", () => {
      resultCounter.style.display = "block"

      element.clearFilter()

      expect(resultCounter.style.display).toBe("none")
    })
  })

  describe("handleClearSearch", () => {
    it("clears search input value", () => {
      searchInput.value = "test"

      element.handleClearSearch({ preventDefault: vi.fn() })

      expect(searchInput.value).toBe("")
    })

    it("clears filter classes", () => {
      const pages = element.querySelectorAll(".sitemap_page")
      pages[0].classList.add("highlight")

      element.handleClearSearch({ preventDefault: vi.fn() })

      expect(pages[0].classList.contains("highlight")).toBe(false)
    })

    it("prevents default link behavior", () => {
      const event = { preventDefault: vi.fn() }

      element.handleClearSearch(event)

      expect(event.preventDefault).toHaveBeenCalled()
    })
  })

  describe("cleanup", () => {
    it("removes event listeners on disconnect", () => {
      const removeEventListenerSpy1 = vi.spyOn(
        searchInput,
        "removeEventListener"
      )
      const removeEventListenerSpy2 = vi.spyOn(
        clearButton,
        "removeEventListener"
      )

      element.disconnectedCallback()

      expect(removeEventListenerSpy1).toHaveBeenCalledWith("input", element)
      expect(removeEventListenerSpy2).toHaveBeenCalledWith("click", element)
    })
  })

  describe("edge cases", () => {
    it("handles missing search input gracefully", () => {
      // Remove all search-related elements first
      document.body.removeChild(searchInput)
      document.body.removeChild(clearButton)
      document.body.removeChild(resultCounter)

      const newElement = document.createElement("alchemy-sitemap")

      // connectedCallback is called automatically when added to DOM
      expect(() => document.body.appendChild(newElement)).not.toThrow()

      newElement.remove()

      // Re-add them for cleanup
      document.body.appendChild(searchInput)
      document.body.appendChild(clearButton)
      document.body.appendChild(resultCounter)
    })

    it("handles missing page name attributes", () => {
      const pageWithoutName = document.createElement("div")
      pageWithoutName.className = "sitemap_page"
      pageWithoutName.scrollIntoView = vi.fn()
      element.querySelector("#sitemap").appendChild(pageWithoutName)

      expect(() => element.filterPages("test")).not.toThrow()
    })
  })

  describe("MutationObserver handling", () => {
    it("sets up MutationObserver on connect", () => {
      expect(element.observer).toBeInstanceOf(MutationObserver)
    })

    it("disconnects observer on disconnect", () => {
      const disconnectSpy = vi.spyOn(element.observer, "disconnect")

      element.disconnectedCallback()

      expect(disconnectSpy).toHaveBeenCalled()
    })

    it("re-initializes sortable when children container is added", async () => {
      const setupSortableSpy = vi.spyOn(element, "setupSortable")

      // Add a new children container
      const newContainer = document.createElement("ul")
      newContainer.id = "page_123_children"
      newContainer.className = "children"
      newContainer.dataset.parentId = "123"
      element.appendChild(newContainer)

      // Wait for MutationObserver to fire
      await new Promise((resolve) => setTimeout(resolve, 0))

      expect(setupSortableSpy).toHaveBeenCalledWith(newContainer)
    })

    it("re-initializes sortables for nested children containers", async () => {
      vi.clearAllMocks()
      const setupSortableSpy = vi.spyOn(element, "setupSortable")

      // Create a container with nested children
      const newContainer = document.createElement("ul")
      newContainer.id = "page_123_children"
      newContainer.className = "children"
      newContainer.dataset.parentId = "123"

      // Add a nested page node with its own children container
      const nestedPageNode = document.createElement("alchemy-page-node")
      nestedPageNode.setAttribute("page-id", "456")

      const nestedChildren = document.createElement("ul")
      nestedChildren.id = "page_456_children"
      nestedChildren.className = "children"
      nestedChildren.dataset.parentId = "456"

      nestedPageNode.appendChild(nestedChildren)
      newContainer.appendChild(nestedPageNode)
      element.appendChild(newContainer)

      // Wait for MutationObserver to fire
      await new Promise((resolve) => setTimeout(resolve, 0))

      // Should initialize sortable for both the main and nested containers
      expect(setupSortableSpy).toHaveBeenCalledWith(newContainer)
      expect(setupSortableSpy).toHaveBeenCalledWith(nestedChildren)
    })

    it("ignores non-children elements", async () => {
      const setupSortableSpy = vi.spyOn(element, "setupSortable")
      const callCountBefore = setupSortableSpy.mock.calls.length

      // Add a non-children element
      const someDiv = document.createElement("div")
      someDiv.className = "some-other-element"
      element.appendChild(someDiv)

      // Wait for MutationObserver to fire
      await new Promise((resolve) => setTimeout(resolve, 0))

      // Should not have called setupSortable for this element
      expect(setupSortableSpy.mock.calls.length).toBe(callCountBefore)
    })
  })
})
