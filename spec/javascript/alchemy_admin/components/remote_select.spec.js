import { renderComponent } from "./component.helper"

import "alchemy_admin/components/page_select"
import {
  hightlightTerm,
  escapeHtml,
  escapeRegExp
} from "alchemy_admin/components/remote_select"

describe("RemoteSelect", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined

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
      expect(component.getAttribute("selection")).toEqual(JSON.stringify(added))
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

describe("escapeHtml", () => {
  it("escapes the characters that would open a tag or attribute", () => {
    expect(escapeHtml(`<a href="x">&</a>`)).toEqual(
      "&lt;a href=&quot;x&quot;&gt;&amp;&lt;/a&gt;"
    )
  })

  it("leaves a plain string unchanged", () => {
    expect(escapeHtml("Home")).toEqual("Home")
  })
})

describe("escapeRegExp", () => {
  it("escapes regex metacharacters so they match literally", () => {
    expect(escapeRegExp("a(b")).toEqual("a\\(b")
  })

  it("leaves a plain string unchanged", () => {
    expect(escapeRegExp("home")).toEqual("home")
  })

  it("produces a pattern that matches the term literally", () => {
    const pattern = new RegExp(escapeRegExp("a.c"))
    expect(pattern.test("a.c")).toBe(true)
    expect(pattern.test("axc")).toBe(false)
  })
})

describe("hightlightTerm", () => {
  const render = (html) => {
    const el = document.createElement("div")
    el.innerHTML = html
    return el
  }

  it("escapes HTML in the name so a payload does not become an element", () => {
    const el = render(hightlightTerm("<img src=x onerror=alert(1)>", ""))
    expect(el.querySelector("img")).toBeNull()
    expect(el.textContent).toEqual("<img src=x onerror=alert(1)>")
  })

  it("highlights the matching term with an em", () => {
    const el = render(hightlightTerm("Home", "om"))
    expect(el.querySelector("em").textContent).toEqual("om")
    expect(el.textContent).toEqual("Home")
  })

  it("highlights the term without unescaping the surrounding name", () => {
    const el = render(hightlightTerm("<b>Home</b>", "Home"))
    expect(el.querySelector("b")).toBeNull()
    expect(el.querySelector("em").textContent).toEqual("Home")
    expect(el.textContent).toEqual("<b>Home</b>")
  })

  it("does not highlight anything when no term was given", () => {
    const el = render(hightlightTerm("Home", undefined))
    expect(el.querySelector("em")).toBeNull()
    expect(el.textContent).toEqual("Home")
  })

  it("treats a term with regex metacharacters literally instead of throwing", () => {
    expect(() => hightlightTerm("a(b", "(")).not.toThrow()
    const el = render(hightlightTerm("a(b", "("))
    expect(el.querySelector("em").textContent).toEqual("(")
  })
})
