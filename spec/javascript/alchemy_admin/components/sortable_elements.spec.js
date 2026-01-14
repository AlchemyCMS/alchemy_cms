import { vi } from "vitest"
import { renderComponent } from "./component.helper"
import Sortable from "sortablejs"
import { growl } from "alchemy_admin/growler"
import { post } from "alchemy_admin/utils/ajax"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import "alchemy_admin/components/sortable_elements"

vi.mock("sortablejs", () => {
  const MockSortable = vi.fn(function (el, options) {
    this.el = el
    this.options = options
  })
  return {
    __esModule: true,
    default: MockSortable
  }
})

vi.mock("alchemy_admin/growler", () => {
  return {
    growl: vi.fn()
  }
})

vi.mock("alchemy_admin/utils/ajax", () => {
  return {
    __esModule: true,
    post: vi.fn(() =>
      Promise.resolve({
        data: {
          message: "Element moved",
          preview_text: "Updated preview text"
        }
      })
    )
  }
})

vi.mock("alchemy_admin/components/preview_window", () => {
  return {
    reloadPreview: vi.fn()
  }
})

function getComponent(html) {
  return renderComponent("alchemy-sortable-elements", html)
}

describe("alchemy-sortable-elements", () => {
  let sortableElements

  const baseHtml = `
    <alchemy-sortable-elements
      data-element-name="article"
      data-droppable-elements="article slide"
    >
      <alchemy-element-editor
        id="element_123"
        class="element-editor"
        data-element-id="123"
        data-element-name="article"
      >
        <div class="element-handle"></div>
      </alchemy-element-editor>
      <alchemy-element-editor
        id="element_456"
        class="element-editor"
        data-element-id="456"
        data-element-name="article"
      >
        <div class="element-handle"></div>
      </alchemy-element-editor>
    </alchemy-sortable-elements>
  `

  beforeEach(() => {
    Alchemy = {
      routes: {
        order_admin_elements_path: "/admin/elements/order"
      }
    }
    vi.clearAllMocks()
  })

  describe("connectedCallback", () => {
    it("initializes Sortable", () => {
      sortableElements = getComponent(baseHtml)
      expect(Sortable).toHaveBeenCalled()
    })

    it("passes correct options to Sortable", () => {
      sortableElements = getComponent(baseHtml)
      const options = Sortable.mock.calls[0][1]

      expect(options.draggable).toBe(".element-editor")
      expect(options.handle).toBe(".element-handle")
      expect(options.ghostClass).toBe("dragged")
      expect(options.animation).toBe(150)
      expect(options.swapThreshold).toBe(0.65)
      expect(options.easing).toBe("cubic-bezier(1, 0, 0, 1)")
    })

    it("configures group with element name", () => {
      sortableElements = getComponent(baseHtml)
      const options = Sortable.mock.calls[0][1]

      expect(options.group.name).toBe("article")
    })

    describe("group.put", () => {
      it("returns true for allowed element names", () => {
        sortableElements = getComponent(baseHtml)
        const options = Sortable.mock.calls[0][1]

        const mockTo = {
          el: { dataset: { droppableElements: "article slide" } }
        }
        const mockItem = { dataset: { elementName: "article" } }

        expect(options.group.put(mockTo, {}, mockItem)).toBe(true)
      })

      it("returns true for second allowed element name", () => {
        sortableElements = getComponent(baseHtml)
        const options = Sortable.mock.calls[0][1]

        const mockTo = {
          el: { dataset: { droppableElements: "article slide" } }
        }
        const mockItem = { dataset: { elementName: "slide" } }

        expect(options.group.put(mockTo, {}, mockItem)).toBe(true)
      })

      it("returns false for disallowed element names", () => {
        sortableElements = getComponent(baseHtml)
        const options = Sortable.mock.calls[0][1]

        const mockTo = {
          el: { dataset: { droppableElements: "article slide" } }
        }
        const mockItem = { dataset: { elementName: "header" } }

        expect(options.group.put(mockTo, {}, mockItem)).toBe(false)
      })
    })
  })

  describe("onStart", () => {
    it("adds droppable-elements class to matching dropzones", () => {
      const html = `
        <alchemy-sortable-elements
          data-element-name="article"
          data-droppable-elements="article"
        >
          <alchemy-element-editor
            class="element-editor"
            data-element-id="123"
            data-element-name="article"
          ></alchemy-element-editor>
        </alchemy-sortable-elements>
        <div data-droppable-elements="article slide"></div>
        <div data-droppable-elements="header"></div>
      `
      sortableElements = getComponent(html)
      const options = Sortable.mock.calls[0][1]

      const mockEvent = {
        item: { dataset: { elementName: "article" } }
      }
      options.onStart(mockEvent)

      const dropzone1 = document.querySelectorAll("[data-droppable-elements]")[1]
      const dropzone2 = document.querySelectorAll("[data-droppable-elements]")[2]

      expect(dropzone1.classList.contains("droppable-elements")).toBe(true)
      expect(dropzone2.classList.contains("droppable-elements")).toBe(false)
    })
  })

  describe("onSort", () => {
    beforeEach(() => {
      sortableElements = getComponent(baseHtml)
    })

    describe("when item is moved to a different container or sorted in the same list", () => {
      it("posts to order endpoint with element_id and position", async () => {
        const options = Sortable.mock.calls[0][1]
        const mockItem = {
          dataset: { elementId: "123" },
          updateTitle: vi.fn()
        }
        const mockTo = sortableElements
        const mockEvent = {
          item: mockItem,
          to: mockTo,
          target: sortableElements,
          newIndex: 1
        }

        options.onSort(mockEvent)

        expect(post).toHaveBeenCalledWith("/admin/elements/order", {
          element_id: "123",
          position: 2
        })
      })

      it("includes parent_element_id when inside nested element", async () => {
        const nestedHtml = `
          <alchemy-element-editor
            id="parent_element"
            class="element-editor"
            data-element-id="999"
          >
            <alchemy-sortable-elements
              data-element-name="article"
              data-droppable-elements="article"
            >
              <alchemy-element-editor
                class="element-editor"
                data-element-id="123"
                data-element-name="article"
              ></alchemy-element-editor>
            </alchemy-sortable-elements>
          </alchemy-element-editor>
        `
        sortableElements = getComponent(nestedHtml)
        const options = Sortable.mock.calls[0][1]

        const mockItem = {
          dataset: { elementId: "123" },
          updateTitle: vi.fn()
        }
        const mockEvent = {
          item: mockItem,
          to: sortableElements,
          target: sortableElements,
          newIndex: 0
        }

        options.onSort(mockEvent)

        expect(post).toHaveBeenCalledWith("/admin/elements/order", {
          element_id: "123",
          position: 1,
          parent_element_id: "999"
        })
      })

      it("shows growl message on success", async () => {
        const options = Sortable.mock.calls[0][1]
        const mockItem = {
          dataset: { elementId: "123" },
          updateTitle: vi.fn()
        }
        const mockEvent = {
          item: mockItem,
          to: sortableElements,
          target: sortableElements,
          newIndex: 0
        }

        options.onSort(mockEvent)
        await vi.waitFor(() => {
          expect(growl).toHaveBeenCalledWith("Element moved")
        })
      })

      it("reloads preview on success", async () => {
        const options = Sortable.mock.calls[0][1]
        const mockItem = {
          dataset: { elementId: "123" },
          updateTitle: vi.fn()
        }
        const mockEvent = {
          item: mockItem,
          to: sortableElements,
          target: sortableElements,
          newIndex: 0
        }

        options.onSort(mockEvent)
        await vi.waitFor(() => {
          expect(reloadPreview).toHaveBeenCalled()
        })
      })

      it("updates item title on success", async () => {
        const options = Sortable.mock.calls[0][1]
        const mockItem = {
          dataset: { elementId: "123" },
          updateTitle: vi.fn()
        }
        const mockEvent = {
          item: mockItem,
          to: sortableElements,
          target: sortableElements,
          newIndex: 0
        }

        options.onSort(mockEvent)
        await vi.waitFor(() => {
          expect(mockItem.updateTitle).toHaveBeenCalledWith(
            "Updated preview text"
          )
        })
      })
    })

    describe("when target differs from to (old list in a move operation)", () => {
      it("does not post to order endpoint", () => {
        const options = Sortable.mock.calls[0][1]
        const mockItem = {
          dataset: { elementId: "123" },
          updateTitle: vi.fn()
        }
        const mockOtherTarget = document.createElement("div")
        const mockEvent = {
          item: mockItem,
          to: sortableElements,
          target: mockOtherTarget,
          newIndex: 0
        }

        options.onSort(mockEvent)

        expect(post).not.toHaveBeenCalled()
      })
    })
  })

  describe("onEnd", () => {
    it("removes droppable-elements class from all dropzones", () => {
      const html = `
        <alchemy-sortable-elements
          data-element-name="article"
          data-droppable-elements="article"
        >
          <alchemy-element-editor
            class="element-editor"
            data-element-id="123"
            data-element-name="article"
          ></alchemy-element-editor>
        </alchemy-sortable-elements>
        <div data-droppable-elements="article" class="droppable-elements"></div>
        <div data-droppable-elements="header" class="droppable-elements"></div>
      `
      sortableElements = getComponent(html)
      const options = Sortable.mock.calls[0][1]

      options.onEnd()

      const dropzones = document.querySelectorAll("[data-droppable-elements]")
      dropzones.forEach((dropzone) => {
        expect(dropzone.classList.contains("droppable-elements")).toBe(false)
      })
    })
  })
})
