import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import { createApp, createSSRApp, h, nextTick, ref, withDirectives } from "vue"
import { renderToString } from "vue/server-renderer"
import { createAlchemyElementDirective, useAlchemyPreview } from "../src/vue.js"

function mount(component) {
  const root = document.createElement("div")
  document.body.append(root)
  const app = createApp(component)
  app.mount(root)
  return { root, app }
}

describe("createAlchemyElementDirective", () => {
  afterEach(() => {
    document.body.innerHTML = ""
  })

  describe("in preview mode", () => {
    const directive = createAlchemyElementDirective({ enabled: true })

    it("sets the element id", () => {
      const { root } = mount({
        render: () => withDirectives(h("div"), [[directive, 1]])
      })

      expect(root.firstChild.dataset.alchemyElement).toEqual("1")
    })

    it("sets the id of the given element", () => {
      const { root } = mount({
        render: () => withDirectives(h("div"), [[directive, { id: 1 }]])
      })

      expect(root.firstChild.dataset.alchemyElement).toEqual("1")
    })

    it("updates the element id", async () => {
      const id = ref(1)
      const { root } = mount({
        render: () => withDirectives(h("div"), [[directive, id.value]])
      })

      id.value = 2
      await nextTick()

      expect(root.firstChild.dataset.alchemyElement).toEqual("2")
    })

    it("removes the element id if there is none", async () => {
      const id = ref(1)
      const { root } = mount({
        render: () => withDirectives(h("div"), [[directive, id.value]])
      })

      id.value = null
      await nextTick()

      expect(root.firstChild.hasAttribute("data-alchemy-element")).toBe(false)
    })

    it("removes the element id if the element is gone", async () => {
      const element = ref({ id: 1 })
      const { root } = mount({
        render: () => withDirectives(h("div"), [[directive, element.value]])
      })

      element.value = null
      await nextTick()

      expect(root.firstChild.hasAttribute("data-alchemy-element")).toBe(false)
    })

    it("sets the element id on a component's root element", () => {
      const Child = { render: () => h("section", "Element") }
      const { root } = mount({
        render: () => withDirectives(h(Child), [[directive, 1]])
      })

      expect(root.querySelector("section").dataset.alchemyElement).toEqual("1")
    })

    it("renders no element id on the server", async () => {
      const app = createSSRApp({
        render: () => withDirectives(h("div"), [[directive, 1]])
      })

      expect(await renderToString(app)).toEqual("<div></div>")
    })
  })

  describe("outside of preview mode", () => {
    it("does not set the element id", () => {
      const directive = createAlchemyElementDirective({ enabled: false })
      const { root } = mount({
        render: () => withDirectives(h("div"), [[directive, 1]])
      })

      expect(root.firstChild.hasAttribute("data-alchemy-element")).toBe(false)
    })
  })
})

describe("useAlchemyPreview", () => {
  let postMessageSpy

  beforeEach(() => {
    Element.prototype.scrollIntoView = vi.fn()
    vi.spyOn(window, "top", "get").mockReturnValue({})
    postMessageSpy = vi
      .spyOn(window.parent, "postMessage")
      .mockImplementation(() => {})
  })

  afterEach(() => {
    vi.restoreAllMocks()
    document.body.innerHTML = ""
  })

  const App = {
    setup() {
      useAlchemyPreview({ adminOrigin: "https://admin.example.com" })
      return () => h("div", { "data-alchemy-element": "1" }, "Element")
    }
  }

  it("starts the preview on mount", () => {
    mount(App)

    expect(postMessageSpy).toHaveBeenCalledWith(
      { message: "Alchemy.previewReady" },
      "https://admin.example.com"
    )
  })

  it("stops the preview on unmount", () => {
    const { app } = mount(App)

    app.unmount()
    postMessageSpy.mockClear()
    document.body.innerHTML = `<div data-alchemy-element="1">Element</div>`
    document.body.firstChild.click()

    expect(postMessageSpy).not.toHaveBeenCalled()
  })
})
