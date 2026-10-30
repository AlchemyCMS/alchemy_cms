import { afterEach, beforeEach, describe, expect, it, vi } from "vitest"
import nuxtModule from "../src/nuxt.js"
import nuxtPlugin from "../src/nuxt-plugin.js"
import { destroy } from "../src/index.js"
import { addedPlugins } from "./stubs/nuxt_kit.js"
import { runtimeConfig } from "./stubs/nuxt_app.js"

describe("Nuxt module", () => {
  let hooks

  function setup(options, publicRuntimeConfig = {}) {
    hooks = {}
    const nuxt = {
      options: {
        runtimeConfig: { public: publicRuntimeConfig },
        build: { transpile: [] }
      },
      hook: (name, callback) => (hooks[name] = callback)
    }
    nuxtModule.setup(options, nuxt)
    return nuxt.options
  }

  afterEach(() => {
    addedPlugins.length = 0
  })

  it("adds the plugin", () => {
    setup({ adminOrigin: "" })

    expect(addedPlugins).toEqual([
      expect.stringMatching(/packages\/preview\/src\/nuxt-plugin\.js$/)
    ])
  })

  it("passes the admin origin to the public runtime config", () => {
    const options = setup({ adminOrigin: "https://admin.example.com" })

    expect(options.runtimeConfig.public.alchemyPreview).toEqual({
      adminOrigin: "https://admin.example.com"
    })
  })

  it("keeps an admin origin set in the runtime config", () => {
    const options = setup(
      { adminOrigin: "https://admin.example.com" },
      { alchemyPreview: { adminOrigin: "https://cms.example.com" } }
    )

    expect(options.runtimeConfig.public.alchemyPreview).toEqual({
      adminOrigin: "https://cms.example.com"
    })
  })

  it("adds the type augmentations to the app", () => {
    setup({ adminOrigin: "" })
    const references = []

    hooks["prepare:types"]({ references })

    expect(references).toEqual([
      { path: expect.stringMatching(/packages\/preview\/types\/nuxt\.d\.ts$/) }
    ])
  })

  it("lets Nuxt bundle the plugin", () => {
    const options = setup({ adminOrigin: "" })

    expect(options.build.transpile).toEqual([
      expect.stringMatching(/packages\/preview\/src\/?$/)
    ])
  })
})

describe("Nuxt plugin", () => {
  let postMessageSpy

  function run() {
    const hooks = {}
    const directives = {}
    const nuxtApp = {
      vueApp: {
        directive: (name, directive) => (directives[name] = directive)
      },
      hook: (name, callback) => (hooks[name] = callback)
    }
    const result = nuxtPlugin(nuxtApp)
    return { hooks, directives, provided: result.provide }
  }

  beforeEach(() => {
    runtimeConfig.public.alchemyPreview = {
      adminOrigin: "https://admin.example.com"
    }
    postMessageSpy = vi
      .spyOn(window.parent, "postMessage")
      .mockImplementation(() => {})
  })

  afterEach(() => {
    destroy()
    vi.restoreAllMocks()
    window.history.replaceState({}, "", "/")
  })

  describe("in the preview frame", () => {
    beforeEach(() => {
      window.history.replaceState(
        {},
        "",
        "/?alchemy_preview_mode=true&alchemy_preview_time=2026-10-28T10:00"
      )
      vi.spyOn(window, "top", "get").mockReturnValue({})
    })

    it("provides the preview state", () => {
      const { provided } = run()

      expect(provided.alchemyPreview).toEqual({
        enabled: true,
        time: "2026-10-28T10:00"
      })
    })

    it("registers the element directive", () => {
      const { directives } = run()

      expect(directives["alchemy-element"].mounted).toBeTypeOf("function")
    })

    it("starts the preview once the app is mounted", () => {
      const { hooks } = run()

      expect(postMessageSpy).not.toHaveBeenCalled()

      hooks["app:mounted"]()

      expect(postMessageSpy).toHaveBeenCalledWith(
        { message: "Alchemy.previewReady" },
        "https://admin.example.com"
      )
    })
  })

  describe("outside of the preview frame", () => {
    beforeEach(() => {
      window.history.replaceState({}, "", "/?alchemy_preview_mode=true")
    })

    it("provides a disabled preview state", () => {
      const { provided } = run()

      expect(provided.alchemyPreview.enabled).toBe(false)
    })

    it("registers a directive that does nothing", () => {
      const { directives } = run()

      expect(directives["alchemy-element"]).toEqual({})
    })

    it("does not start the preview", () => {
      const { hooks } = run()

      expect(hooks["app:mounted"]).toBeUndefined()
    })
  })
})
