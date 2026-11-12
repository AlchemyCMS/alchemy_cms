import { beforeEach, afterEach, describe, expect, it, vi } from "vitest"
import { init, destroy, previewState } from "../src/index.js"

const HOVER_OUTLINE = "2px dashed #f0b437"
const SELECTED_OUTLINE = "2px dashed #90b9d0"

function element(id) {
  return document.querySelector(`[data-alchemy-element="${id}"]`)
}

function hover(target) {
  target.dispatchEvent(new MouseEvent("mouseover", { bubbles: true }))
}

function unhover(target) {
  target.dispatchEvent(new MouseEvent("mouseout", { bubbles: true }))
}

function receive(data, origin = window.location.origin) {
  window.dispatchEvent(new MessageEvent("message", { data, origin }))
}

describe("preview", () => {
  let postMessageSpy

  beforeEach(() => {
    document.body.innerHTML = `
      <div data-alchemy-element="1">Element one</div>
      <div data-alchemy-element="2">Element two</div>
    `
    Element.prototype.scrollIntoView = vi.fn()
    vi.spyOn(window, "top", "get").mockReturnValue({})
    postMessageSpy = vi
      .spyOn(window.parent, "postMessage")
      .mockImplementation(() => {})
  })

  afterEach(() => {
    destroy()
    vi.restoreAllMocks()
    document.body.innerHTML = ""
  })

  it("does nothing outside of a frame", () => {
    vi.spyOn(window, "top", "get").mockReturnValue(window)
    init()

    hover(element(1))

    expect(postMessageSpy).not.toHaveBeenCalled()
    expect(element(1).style.outline).toEqual("")
  })

  it("does not create a global Alchemy object", () => {
    init()

    expect(window.Alchemy).toBeUndefined()
  })

  it("starts itself when loaded as standalone script", async () => {
    await import("../src/standalone.js")

    expect(postMessageSpy).toHaveBeenCalledWith(
      { message: "Alchemy.previewReady" },
      window.location.origin
    )
  })

  it("handles elements added after init", () => {
    init()

    // Client side rendered pages and host layouts rendering content below the
    // alchemy/edit_mode partial add elements after the preview started.
    document.body.innerHTML = `<div data-alchemy-element="3">Element three</div>`
    hover(element(3))

    expect(element(3).style.outline).toEqual(HOVER_OUTLINE)

    receive({ message: "Alchemy.focusElement", element_id: 3 })

    expect(element(3).style.outline).toEqual(SELECTED_OUTLINE)
  })

  it("notifies the parent window that the preview is ready", () => {
    init()

    expect(postMessageSpy).toHaveBeenCalledWith(
      { message: "Alchemy.previewReady" },
      window.location.origin
    )
  })

  it("does not register twice if initialized twice", () => {
    init()
    init()
    postMessageSpy.mockClear()

    element(2).click()

    expect(postMessageSpy).toHaveBeenCalledTimes(1)
  })

  describe("with an admin on another origin", () => {
    const adminOrigin = "https://admin.example.com"

    beforeEach(() => {
      init({ adminOrigin })
    })

    it("sends messages to the admin origin only", () => {
      element(2).click()

      expect(postMessageSpy).toHaveBeenCalledWith(
        { message: "Alchemy.previewReady" },
        adminOrigin
      )
      expect(postMessageSpy).toHaveBeenCalledWith(
        { message: "Alchemy.focusElementEditor", element_id: "2" },
        adminOrigin
      )
    })

    it("accepts messages from the admin origin", () => {
      receive({ message: "Alchemy.focusElement", element_id: 2 }, adminOrigin)

      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("ignores messages from other origins", () => {
      receive({ message: "Alchemy.focusElement", element_id: 2 })

      expect(element(2).style.outline).toEqual("")
    })
  })

  describe("destroy", () => {
    it("removes all outlines", () => {
      init()
      element(1).click()
      hover(element(2))

      destroy()

      expect(element(1).style.outline).toEqual("")
      expect(element(2).style.outline).toEqual("")
    })

    it("stops reacting to the page and the admin", () => {
      init()
      destroy()
      postMessageSpy.mockClear()

      hover(element(1))
      element(2).click()
      receive({ message: "Alchemy.focusElement", element_id: 1 })

      expect(element(1).style.outline).toEqual("")
      expect(element(2).style.outline).toEqual("")
      expect(postMessageSpy).not.toHaveBeenCalled()
    })
  })

  describe("hovering an element", () => {
    it("outlines the element", () => {
      init()

      hover(element(1))

      expect(element(1).style.outline).toEqual(HOVER_OUTLINE)
      expect(element(1).style.cursor).toEqual("pointer")
    })

    it("removes the outline again on mouseout", () => {
      init()

      hover(element(1))
      unhover(element(1))

      expect(element(1).style.outline).toEqual("")
      expect(element(1).style.cursor).toEqual("")
    })

    it("keeps a selected element outlined as selected", () => {
      init()

      element(1).click()
      hover(element(1))
      unhover(element(1))

      expect(element(1).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("outlines nested elements and the elements they are nested in", () => {
      element(1).innerHTML = `<div data-alchemy-element="3">Nested</div>`
      init()

      hover(element(3))

      expect(element(3).style.outline).toEqual(HOVER_OUTLINE)
      expect(element(1).style.outline).toEqual(HOVER_OUTLINE)
    })
  })

  describe("clicking an element", () => {
    it("focuses the element editor in the admin window", () => {
      init()

      element(2).click()

      expect(postMessageSpy).toHaveBeenCalledWith(
        { message: "Alchemy.focusElementEditor", element_id: "2" },
        window.location.origin
      )
    })

    it("marks the element as selected and scrolls to it", () => {
      init()

      element(2).click()

      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
      expect(element(2).scrollIntoView).toHaveBeenCalledWith({
        behavior: "smooth",
        block: "start"
      })
    })

    it("deselects the previously selected element", () => {
      init()

      element(1).click()
      element(2).click()

      expect(element(1).style.outline).toEqual("")
    })

    it("keeps client side routers from navigating", () => {
      element(2).innerHTML = `<a href="/other-page">Link</a>`
      let navigated = false
      // Mirrors how routers like vue-router guard their link click handlers
      element(2)
        .querySelector("a")
        .addEventListener("click", (event) => {
          if (!event.defaultPrevented) navigated = true
        })
      init()

      element(2).querySelector("a").click()

      expect(navigated).toBe(false)
      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("lets interactive content inside the element handle the click", () => {
      element(2).innerHTML = `<button>Next slide</button>`
      const onButtonClick = vi.fn()
      element(2)
        .querySelector("button")
        .addEventListener("click", onButtonClick)
      init()

      element(2).querySelector("button").click()

      expect(onButtonClick).toHaveBeenCalled()
      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("lets details inside the element toggle", () => {
      element(2).innerHTML = `<details><summary>More</summary>Text</details>`
      init()

      element(2).querySelector("summary").click()

      expect(element(2).querySelector("details").open).toBe(true)
      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("lets form controls inside the element change", () => {
      element(2).innerHTML = `<input type="checkbox">`
      init()

      element(2).querySelector("input").click()

      expect(element(2).querySelector("input").checked).toBe(true)
      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("keeps forms inside the element from being submitted", () => {
      element(2).innerHTML = `<form><button>Send</button></form>`
      const onSubmit = vi.fn((event) => event.preventDefault())
      element(2).querySelector("form").addEventListener("submit", onSubmit)
      init()

      element(2).querySelector("button").click()

      expect(onSubmit).not.toHaveBeenCalled()
      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("selects the innermost of nested elements", () => {
      element(1).innerHTML = `<div data-alchemy-element="3">Nested</div>`
      init()

      element(3).click()

      expect(element(3).style.outline).toEqual(SELECTED_OUTLINE)
      expect(element(1).style.outline).toEqual("")
      expect(postMessageSpy).toHaveBeenCalledWith(
        { message: "Alchemy.focusElementEditor", element_id: "3" },
        window.location.origin
      )
    })
  })

  describe("Alchemy.focusElement message", () => {
    it("selects the element with the given id", () => {
      init()

      receive({ message: "Alchemy.focusElement", element_id: 2 })

      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("warns if no element with the given id exists", () => {
      const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {})
      init()

      receive({ message: "Alchemy.focusElement", element_id: 666 })

      expect(warnSpy).toHaveBeenCalledWith(
        "Could not focus element with id",
        666
      )
    })
  })

  describe("Alchemy.blurElements message", () => {
    it("deselects all elements", () => {
      init()

      element(1).click()
      receive({ message: "Alchemy.blurElements" })

      expect(element(1).style.outline).toEqual("")
    })

    it("outlines a formerly selected element on hover again", () => {
      init()

      element(1).click()
      receive({ message: "Alchemy.blurElements" })
      hover(element(1))

      expect(element(1).style.outline).toEqual(HOVER_OUTLINE)
    })
  })

  it("logs unknown messages", () => {
    const infoSpy = vi.spyOn(console, "info").mockImplementation(() => {})
    init()

    const data = { message: "Alchemy.somethingElse" }
    receive(data)

    expect(infoSpy).toHaveBeenCalledWith("Received unknown message!", data)
  })
})

describe("previewState", () => {
  afterEach(() => {
    vi.restoreAllMocks()
    window.history.replaceState({}, "", "/")
  })

  function framed() {
    vi.spyOn(window, "top", "get").mockReturnValue({})
  }

  it("is enabled in preview mode inside a frame", () => {
    window.history.replaceState({}, "", "/?alchemy_preview_mode=true")
    framed()

    expect(previewState().enabled).toBe(true)
  })

  it("is disabled outside of a frame", () => {
    window.history.replaceState({}, "", "/?alchemy_preview_mode=true")

    expect(previewState().enabled).toBe(false)
  })

  it("is disabled without preview mode", () => {
    framed()

    expect(previewState().enabled).toBe(false)
  })

  it("contains the preview time", () => {
    window.history.replaceState(
      {},
      "",
      "/?alchemy_preview_mode=true&alchemy_preview_time=2026-10-28T10:00"
    )
    framed()

    expect(previewState().time).toEqual("2026-10-28T10:00")
  })

  it("has no preview time without the parameter", () => {
    expect(previewState().time).toBeNull()
  })
})
