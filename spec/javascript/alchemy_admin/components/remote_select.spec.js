import { renderComponent } from "./component.helper"

import "alchemy_admin/components/page_select"
import { RemoteSelect } from "alchemy_admin/components/remote_select"

// A minimal subclass so the slot render helpers can be exercised through every
// slot shape without depending on a real select's data.
class TestRemoteSelect extends RemoteSelect {
  entrySlots = {}
  selectionSlots = {}

  _entry() {
    return this.entrySlots
  }

  _selectedEntry() {
    return this.selectionSlots
  }
}
customElements.define("alchemy-test-remote-select", TestRemoteSelect)

const parse = (html) => {
  const wrapper = document.createElement("div")
  wrapper.innerHTML = html
  return wrapper.firstElementChild
}

describe("RemoteSelect", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  describe("slot rendering", () => {
    beforeEach(() => {
      component = renderComponent(
        "alchemy-test-remote-select",
        `<alchemy-test-remote-select><input type="text"></alchemy-test-remote-select>`
      )
    })

    describe("a dropdown option", () => {
      it("renders an icon lead", () => {
        component.entrySlots = { icon: "file-3", primary: "Home" }
        const entry = parse(component._renderListEntry({}, ""))
        const icon = entry.querySelector(".remote-select--icon")
        expect(icon.getAttribute("name")).toEqual("file-3")
        expect(entry.querySelector(".remote-select--media")).toBeNull()
      })

      it("renders a media lead when no icon is given", () => {
        component.entrySlots = { media: "/thumb.png", primary: "Home" }
        const entry = parse(component._renderListEntry({}, ""))
        const media = entry.querySelector(".remote-select--media")
        expect(media.tagName).toEqual("IMG")
        expect(media.getAttribute("src")).toEqual("/thumb.png")
      })

      it("prefers the icon when both are given", () => {
        component.entrySlots = { icon: "file-3", media: "/thumb.png" }
        const entry = parse(component._renderListEntry({}, ""))
        expect(entry.querySelector(".remote-select--icon")).not.toBeNull()
        expect(entry.querySelector(".remote-select--media")).toBeNull()
      })

      it("keeps the pre-highlighted primary text raw", () => {
        component.entrySlots = { primary: "H<em>om</em>e" }
        const entry = parse(component._renderListEntry({}, ""))
        expect(entry.querySelector(".remote-select--primary em")).not.toBeNull()
      })

      it("escapes a plain aside", () => {
        component.entrySlots = { primary: "Home", aside: "<b>Site</b>" }
        const aside = parse(component._renderListEntry({}, "")).querySelector(
          ".remote-select--aside"
        )
        expect(aside.querySelector("b")).toBeNull()
        expect(aside.textContent).toEqual("<b>Site</b>")
      })

      it("head truncates a secondary via a bdi wrapper", () => {
        component.entrySlots = {
          primary: "Home",
          secondary: { text: "/a/b/c", truncate: "head" }
        }
        const secondary = parse(
          component._renderListEntry({}, "")
        ).querySelector(".remote-select--secondary")
        expect(
          secondary.classList.contains("remote-select--truncate-head")
        ).toBe(true)
        expect(secondary.querySelector("bdi").textContent).toEqual("/a/b/c")
      })

      it("renders a badge as a pill", () => {
        component.entrySlots = { primary: "Home", secondaryAside: { badge: "en" } }
        const badge = parse(component._renderListEntry({}, "")).querySelector(
          ".remote-select--secondary-aside"
        )
        expect(badge.classList.contains("remote-select--badge")).toBe(true)
        expect(badge.textContent).toEqual("en")
      })

      it("omits a cell whose slot is falsy", () => {
        component.entrySlots = {
          primary: "Home",
          aside: undefined,
          secondary: { text: "" },
          secondaryAside: { badge: null }
        }
        const entry = parse(component._renderListEntry({}, ""))
        expect(entry.querySelector(".remote-select--aside")).toBeNull()
        expect(entry.querySelector(".remote-select--secondary")).toBeNull()
        expect(entry.querySelector(".remote-select--secondary-aside")).toBeNull()
      })
    })

    describe("the selected item", () => {
      it("renders the lead, the name, and a shrinking secondary", () => {
        component.selectionSlots = {
          icon: "file-3",
          primary: "Home",
          secondary: { text: "/home", truncate: "head" }
        }
        const selection = parse(component._renderResult({}))
        expect(selection.classList.contains("remote-select--selection")).toBe(
          true
        )
        expect(selection.querySelector(".remote-select--icon")).not.toBeNull()
        expect(
          selection.querySelector(".remote-select--selection-name").textContent
        ).toEqual("Home")
        expect(
          selection.querySelector(".remote-select--selection-aside bdi")
            .textContent
        ).toEqual("/home")
      })

      it("omits the secondary when it is not given", () => {
        component.selectionSlots = { icon: "menu-2", primary: "A node" }
        const selection = parse(component._renderResult({}))
        expect(
          selection.querySelector(".remote-select--selection-aside")
        ).toBeNull()
      })
    })
  })

  describe("onChange", () => {
    beforeEach(() => {
      const html = `
        <alchemy-page-select>
          <input type="text">
        </alchemy-page-select>
      `
      component = renderComponent("alchemy-page-select", html)
    })

    it("updates the selection attribute when an item is added", () => {
      const added = { id: 1, name: "A page" }
      component.onChange({ added, removed: null })
      expect(component.getAttribute("selection")).toEqual(
        JSON.stringify(added)
      )
    })

    it("does not change the selection attribute when nothing is added", () => {
      const previous = JSON.stringify({ id: 1, name: "Previous" })
      component.setAttribute("selection", previous)
      component.onChange({ added: null, removed: { id: 1 } })
      expect(component.getAttribute("selection")).toEqual(previous)
    })

    it("dispatches an Alchemy.RemoteSelect.Change event", () => {
      const listener = vi.fn()
      component.addEventListener("Alchemy.RemoteSelect.Change", listener)
      const added = { id: 2, name: "Another page" }
      component.onChange({ added, removed: null })
      expect(listener).toHaveBeenCalledOnce()
      expect(listener.mock.calls[0][0].detail).toEqual({
        added,
        removed: null
      })
    })
  })
})
