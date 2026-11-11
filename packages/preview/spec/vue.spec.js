import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import { createApp, createSSRApp, h, nextTick, ref, withDirectives } from "vue"
import { renderToString } from "vue/server-renderer"
import {
  AlchemyElement,
  createAlchemyElementDirective,
  useAlchemyPreview
} from "../src/vue.js"

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

describe("AlchemyElement", () => {
  const TextElement = {
    props: ["element", "index"],
    render() {
      return h("article", { class: "text" }, [
        `${this.element.name} ${this.index}`,
        this.$slots.default?.()
      ])
    }
  }

  function render(element = ref({ id: 1, name: "text" })) {
    return {
      setup() {
        return () =>
          h(
            AlchemyElement,
            { is: TextElement, element: element.value, index: 3 },
            { default: () => "slot" }
          )
      }
    }
  }

  function mountElement(state, element) {
    const root = document.createElement("div")
    document.body.append(root)
    const app = createApp(render(element))
    app.directive("alchemy-element", createAlchemyElementDirective(state))
    app.mount(root)
    return root
  }

  afterEach(() => {
    document.body.innerHTML = ""
  })

  it("renders the given component with the element, attributes and slots", () => {
    const root = mountElement({ enabled: false })

    expect(root.innerHTML).toEqual('<article class="text">text 3slot</article>')
  })

  it("resolves globally registered components by name", () => {
    const root = document.createElement("div")
    document.body.append(root)
    const app = createApp({
      render: () =>
        h(AlchemyElement, {
          is: "TextElement",
          element: { id: 1, name: "text" }
        })
    })
    app.component("TextElement", TextElement)
    app.directive(
      "alchemy-element",
      createAlchemyElementDirective({ enabled: true })
    )
    app.mount(root)

    expect(root.querySelector("article").dataset.alchemyElement).toEqual("1")
  })

  describe("in preview mode", () => {
    it("marks the component's root element", () => {
      const root = mountElement({ enabled: true })

      expect(root.querySelector("article").dataset.alchemyElement).toEqual("1")
    })

    it("follows changes of the element", async () => {
      const element = ref({ id: 1, name: "text" })
      const root = mountElement({ enabled: true }, element)

      element.value = { id: 2, name: "text" }
      await nextTick()

      expect(root.querySelector("article").dataset.alchemyElement).toEqual("2")
    })

    it("marks the element after hydrating server rendered markup", async () => {
      const server = createSSRApp(render())
      server.directive(
        "alchemy-element",
        createAlchemyElementDirective({ enabled: false })
      )
      const html = await renderToString(server)
      const root = document.createElement("div")
      root.innerHTML = html
      document.body.append(root)
      const warn = vi.spyOn(console, "warn").mockImplementation(() => {})

      const client = createSSRApp(render())
      client.directive(
        "alchemy-element",
        createAlchemyElementDirective({ enabled: true })
      )
      client.mount(root)

      expect(html).not.toContain("data-alchemy-element")
      expect(root.querySelector("article").dataset.alchemyElement).toEqual("1")
      expect(warn).not.toHaveBeenCalled()
      warn.mockRestore()
    })
  })

  describe("outside of preview mode", () => {
    it("does not mark the component's root element", () => {
      const root = mountElement({ enabled: false })

      expect(
        root.querySelector("article").hasAttribute("data-alchemy-element")
      ).toBe(false)
    })
  })

  it("renders no element id on the server, even in preview mode", async () => {
    const app = createSSRApp(render())
    app.directive(
      "alchemy-element",
      createAlchemyElementDirective({ enabled: true })
    )

    expect(await renderToString(app)).not.toContain("data-alchemy-element")
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
