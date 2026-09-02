import { renderComponent } from "./component.helper"

import "alchemy_admin/components/attachment_select"

const PAYLOAD = "<img src=x onerror=alert(1)>"

describe("alchemy-attachment-select", () => {
  /**
   *
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  describe("_renderListEntry", () => {
    const render = (attachment, term = "") => {
      const el = document.createElement("div")
      el.innerHTML = component._renderListEntry(attachment, term)
      return el
    }

    beforeEach(() => {
      const html = `
        <alchemy-attachment-select>
          <input type="text">
        </alchemy-attachment-select>
      `
      component = renderComponent("alchemy-attachment-select", html)
    })

    it("escapes the attachment name", () => {
      const name = `Report ${PAYLOAD}`
      const el = render({ name, icon_css_class: "file-pdf" }, "Report")
      expect(el.querySelector("img")).toBeNull()
      expect(
        el
          .querySelector(".attachment-select--attachment-name")
          .textContent.trim()
      ).toEqual(name)
    })

    it("escapes the icon css class so it cannot break out of the attribute", () => {
      const el = render({ name: "A file", icon_css_class: `x"><img src=y>` })
      expect(el.querySelector("img")).toBeNull()
      expect(el.querySelector("alchemy-icon").getAttribute("name")).toEqual(
        `x"><img src=y>`
      )
    })
  })
})
