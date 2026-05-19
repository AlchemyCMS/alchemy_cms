import { renderComponent } from "./component.helper"

import "alchemy_admin/components/page_select"

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
