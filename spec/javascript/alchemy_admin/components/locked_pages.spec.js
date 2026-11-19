import { vi } from "vitest"
import "alchemy_admin/components/locked_pages"
import { renderComponent } from "./component.helper"

describe("alchemy-locked-pages", () => {
  let component, list, dropdown

  // jsdom has no layout, so sizes and scroll positions are faked.
  const layout = ({ scrollWidth, clientWidth, scrollLeft = 0 }) => {
    Object.defineProperty(list, "scrollWidth", {
      value: scrollWidth,
      configurable: true
    })
    Object.defineProperty(list, "clientWidth", {
      value: clientWidth,
      configurable: true
    })
    list.scrollLeft = scrollLeft
  }

  beforeAll(() => {
    globalThis.ResizeObserver ??= class {
      observe() {}
      disconnect() {}
    }
  })

  beforeEach(() => {
    component = renderComponent(
      "alchemy-locked-pages",
      `
        <alchemy-locked-pages id="locked_pages">
          <div class="locked-pages-list">
            <div class="locked_page" id="locked_page_1"><a href="/admin/pages/1/edit">Home</a></div>
            <div class="locked_page current" id="locked_page_2"><a href="/admin/pages/2/edit">About</a><input type="hidden" id="redirect_to"></div>
          </div>
          <sl-dropdown class="locked-pages-menu">
            <button slot="trigger"><span class="locked-pages-count">2</span></button>
            <div class="locked-pages-menu-list"></div>
          </sl-dropdown>
        </alchemy-locked-pages>
      `
    )
    list = component.querySelector(".locked-pages-list")
    dropdown = component.querySelector("sl-dropdown")
  })

  it("centers the current page in the row", () => {
    const current = component.querySelector(".locked_page.current")
    list.getBoundingClientRect = () => ({ left: 0, width: 300 })
    current.getBoundingClientRect = () => ({ left: 500, width: 100 })
    layout({ scrollWidth: 900, clientWidth: 300 })
    component.update()
    expect(list.scrollLeft).toEqual(400)
  })

  describe("when the tabs fit", () => {
    it("is not overflowing", () => {
      layout({ scrollWidth: 300, clientWidth: 300 })
      component.update()
      expect(component.hasAttribute("overflowing")).toBe(false)
    })
  })

  describe("when the tabs do not fit", () => {
    beforeEach(() => {
      layout({ scrollWidth: 900, clientWidth: 300 })
      component.update()
    })

    it("is overflowing", () => {
      expect(component.hasAttribute("overflowing")).toBe(true)
    })

    it("fades out the end while scrolled to the start", () => {
      expect(component.hasAttribute("fade-start")).toBe(false)
      expect(component.hasAttribute("fade-end")).toBe(true)
    })

    it("fades out both sides while scrolled to the middle", () => {
      layout({ scrollWidth: 900, clientWidth: 300, scrollLeft: 200 })
      list.dispatchEvent(new Event("scroll"))
      expect(component.hasAttribute("fade-start")).toBe(true)
      expect(component.hasAttribute("fade-end")).toBe(true)
    })
  })

  it("updates the count when a page is removed", async () => {
    component.querySelector("#locked_page_1").remove()
    await new Promise((resolve) => setTimeout(resolve))
    expect(component.querySelector(".locked-pages-count").textContent).toEqual(
      "1"
    )
  })

  describe("opening the menu", () => {
    beforeEach(() => {
      dropdown.hide = vi.fn()
      dropdown.dispatchEvent(new CustomEvent("sl-show"))
    })

    it("lists all locked pages without duplicating their ids", () => {
      const rows = component.querySelectorAll(
        ".locked-pages-menu-list .locked_page"
      )
      expect(rows.length).toEqual(2)
      expect(component.querySelectorAll("[id='locked_page_1']").length).toEqual(
        1
      )
      expect(component.querySelectorAll("[id='redirect_to']").length).toEqual(1)
    })

    it("closes the menu when a page is unlocked from it", () => {
      component
        .querySelector(".locked-pages-menu-list")
        .dispatchEvent(new Event("submit", { bubbles: true }))
      expect(dropdown.hide).toHaveBeenCalled()
    })
  })
})
