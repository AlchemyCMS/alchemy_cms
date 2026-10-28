import { beforeEach, afterEach, describe, expect, it, vi } from "vitest"

const HOVER_OUTLINE = "2px dashed #f0b437"
const SELECTED_OUTLINE = "2px dashed #90b9d0"

// The preview bundle runs on import, so each example needs a fresh module
// registry to re-run it against the DOM that example just set up.
async function loadPreview() {
  vi.resetModules()
  await import("../../app/javascript/preview.js")
}

function element(id) {
  return document.querySelector(`[data-alchemy-element="${id}"]`)
}

describe("preview", () => {
  let postMessageSpy
  let listenerSpy

  beforeEach(() => {
    // Every import registers a fresh window message listener, and jsdom keeps
    // one window for the whole file. Recording them here so they can be
    // unregistered again keeps earlier examples from answering later messages.
    listenerSpy = vi.spyOn(window, "addEventListener")

    document.body.innerHTML = `
      <div data-alchemy-element="1">Element one</div>
      <div data-alchemy-element="2">Element two</div>
    `
    Element.prototype.scrollIntoView = vi.fn()
    postMessageSpy = vi
      .spyOn(window.parent, "postMessage")
      .mockImplementation(() => {})
  })

  afterEach(() => {
    listenerSpy.mock.calls.forEach((args) =>
      window.removeEventListener(...args)
    )
    vi.restoreAllMocks()
    document.body.innerHTML = ""
  })

  it("does not create a global Alchemy object", async () => {
    await loadPreview()

    expect(window.Alchemy).toBeUndefined()
  })

  it("notifies the parent window that the preview is ready", async () => {
    await loadPreview()

    expect(postMessageSpy).toHaveBeenCalledWith(
      { message: "Alchemy.previewReady" },
      window.location.origin
    )
  })

  describe("hovering an element", () => {
    it("outlines the element", async () => {
      await loadPreview()

      element(1).dispatchEvent(new MouseEvent("mouseover"))

      expect(element(1).style.outline).toEqual(HOVER_OUTLINE)
      expect(element(1).style.cursor).toEqual("pointer")
    })

    it("removes the outline again on mouseout", async () => {
      await loadPreview()

      element(1).dispatchEvent(new MouseEvent("mouseover"))
      element(1).dispatchEvent(new MouseEvent("mouseout"))

      expect(element(1).style.outline).toEqual("")
      expect(element(1).style.cursor).toEqual("")
    })

    it("keeps a selected element outlined as selected", async () => {
      await loadPreview()

      element(1).click()
      element(1).dispatchEvent(new MouseEvent("mouseover"))
      element(1).dispatchEvent(new MouseEvent("mouseout"))

      expect(element(1).style.outline).toEqual(SELECTED_OUTLINE)
    })
  })

  describe("clicking an element", () => {
    it("focuses the element editor in the admin window", async () => {
      await loadPreview()

      element(2).click()

      expect(postMessageSpy).toHaveBeenCalledWith(
        { message: "Alchemy.focusElementEditor", element_id: "2" },
        window.location.origin
      )
    })

    it("marks the element as selected and scrolls to it", async () => {
      await loadPreview()

      element(2).click()

      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
      expect(element(2).scrollIntoView).toHaveBeenCalledWith({
        behavior: "smooth",
        block: "start"
      })
    })

    it("deselects the previously selected element", async () => {
      await loadPreview()

      element(1).click()
      element(2).click()

      expect(element(1).style.outline).toEqual("")
    })

    it("keeps client side routers from navigating", async () => {
      element(2).innerHTML = `<a href="/other-page">Link</a>`
      let navigated = false
      // Mirrors how routers like vue-router guard their link click handlers
      element(2)
        .querySelector("a")
        .addEventListener("click", (event) => {
          if (!event.defaultPrevented) navigated = true
        })
      await loadPreview()

      element(2).querySelector("a").click()

      expect(navigated).toBe(false)
      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("lets interactive content inside the element handle the click", async () => {
      element(2).innerHTML = `<button>Next slide</button>`
      const onButtonClick = vi.fn()
      element(2)
        .querySelector("button")
        .addEventListener("click", onButtonClick)
      await loadPreview()

      element(2).querySelector("button").click()

      expect(onButtonClick).toHaveBeenCalled()
      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("lets details inside the element toggle", async () => {
      element(2).innerHTML = `<details><summary>More</summary>Text</details>`
      await loadPreview()

      element(2).querySelector("summary").click()

      expect(element(2).querySelector("details").open).toBe(true)
      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("lets form controls inside the element change", async () => {
      element(2).innerHTML = `<input type="checkbox">`
      await loadPreview()

      element(2).querySelector("input").click()

      expect(element(2).querySelector("input").checked).toBe(true)
      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("keeps forms inside the element from being submitted", async () => {
      element(2).innerHTML = `<form><button>Send</button></form>`
      const onSubmit = vi.fn((event) => event.preventDefault())
      element(2).querySelector("form").addEventListener("submit", onSubmit)
      await loadPreview()

      element(2).querySelector("button").click()

      expect(onSubmit).not.toHaveBeenCalled()
      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("selects the innermost of nested elements", async () => {
      element(1).innerHTML = `<div data-alchemy-element="3">Nested</div>`
      await loadPreview()

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
    it("selects the element with the given id", async () => {
      await loadPreview()

      window.dispatchEvent(
        new MessageEvent("message", {
          data: { message: "Alchemy.focusElement", element_id: 2 }
        })
      )

      expect(element(2).style.outline).toEqual(SELECTED_OUTLINE)
    })

    it("warns if no element with the given id exists", async () => {
      const warnSpy = vi.spyOn(console, "warn").mockImplementation(() => {})
      await loadPreview()

      window.dispatchEvent(
        new MessageEvent("message", {
          data: { message: "Alchemy.focusElement", element_id: 666 }
        })
      )

      expect(warnSpy).toHaveBeenCalledWith(
        "Could not focus element with id",
        666
      )
    })
  })

  describe("Alchemy.blurElements message", () => {
    it("deselects all elements", async () => {
      await loadPreview()

      element(1).click()
      window.dispatchEvent(
        new MessageEvent("message", {
          data: { message: "Alchemy.blurElements" }
        })
      )

      expect(element(1).style.outline).toEqual("")
    })

    it("outlines a formerly selected element on hover again", async () => {
      await loadPreview()

      element(1).click()
      window.dispatchEvent(
        new MessageEvent("message", {
          data: { message: "Alchemy.blurElements" }
        })
      )
      element(1).dispatchEvent(new MouseEvent("mouseover"))

      expect(element(1).style.outline).toEqual(HOVER_OUTLINE)
    })
  })

  it("logs unknown messages", async () => {
    const infoSpy = vi.spyOn(console, "info").mockImplementation(() => {})
    await loadPreview()

    const data = { message: "Alchemy.somethingElse" }
    window.dispatchEvent(new MessageEvent("message", { data }))

    expect(infoSpy).toHaveBeenCalledWith("Received unknown message!", data)
  })
})
