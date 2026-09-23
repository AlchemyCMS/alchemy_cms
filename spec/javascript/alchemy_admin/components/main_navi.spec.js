import { vi } from "vitest"

const { openConfirmDialogMock } = vi.hoisted(() => {
  return {
    openConfirmDialogMock: vi.fn().mockResolvedValue(false)
  }
})

vi.mock("alchemy_admin/confirm_dialog", () => ({
  openConfirmDialog: openConfirmDialogMock
}))

import { renderComponent } from "./component.helper"
import "alchemy_admin/components/main_navi"

const mainNavi = `
  <alchemy-main-navi id="main_navi">
    <alchemy-main-navi-entry class="main_navi_entry has_sub_navigation">
      <a href="/admin/pages"><label>Pages</label></a>
      <div class="sub_navigation">
        <div class="subnavi_tab">
          <a href="/admin/layoutpages">Layoutpages</a>
        </div>
      </div>
    </alchemy-main-navi-entry>
    <a href="/admin/custom" id="custom_entry">Custom module</a>
  </alchemy-main-navi>
`

const markPageDirty = () => {
  const editor = document.createElement("alchemy-element-editor")
  editor.classList.add("dirty")
  document.body.append(editor)
}

// Click the link and report whether the navigation was cancelled by the time
// the event left the navigation. The click is swallowed afterwards, because
// jsdom cannot navigate and would log the attempt as an unimplemented feature.
const clickAndCaptureCancellation = (link) => {
  let cancelled = null

  document.body.addEventListener(
    "click",
    (event) => {
      cancelled = event.defaultPrevented
      event.preventDefault()
    },
    { once: true }
  )
  link.dispatchEvent(
    new MouseEvent("click", { bubbles: true, cancelable: true })
  )

  return cancelled
}

describe("alchemy-main-navi", () => {
  beforeEach(() => {
    openConfirmDialogMock.mockClear().mockResolvedValue(false)
    globalThis.Turbo = { visit: vi.fn() }
  })

  describe("with unsaved changes on the page", () => {
    beforeEach(() => {
      renderComponent("alchemy-main-navi", mainNavi)
      markPageDirty()
    })

    it("asks before leaving through a navigation entry", () => {
      const link = document.querySelector("alchemy-main-navi-entry > a")

      expect(clickAndCaptureCancellation(link)).toBe(true)
      expect(openConfirmDialogMock).toHaveBeenCalled()
    })

    it("asks before leaving through a sub navigation link", () => {
      const link = document.querySelector(".sub_navigation a")

      expect(clickAndCaptureCancellation(link)).toBe(true)
      expect(openConfirmDialogMock).toHaveBeenCalled()
    })

    it("asks before leaving through a link added by a host application", () => {
      const link = document.getElementById("custom_entry")

      expect(clickAndCaptureCancellation(link)).toBe(true)
      expect(openConfirmDialogMock).toHaveBeenCalled()
    })

    it("navigates to the link once the user confirms", async () => {
      openConfirmDialogMock.mockResolvedValue(true)
      const link = document.getElementById("custom_entry")

      clickAndCaptureCancellation(link)
      await openConfirmDialogMock.mock.results[0].value

      expect(globalThis.Turbo.visit).toHaveBeenCalledWith("/admin/custom")
    })

    it("ignores clicks that did not happen on a link", () => {
      const navi = document.getElementById("main_navi")

      expect(clickAndCaptureCancellation(navi)).toBe(false)
      expect(openConfirmDialogMock).not.toHaveBeenCalled()
    })

    it("stops guarding once it is disconnected", () => {
      const navi = document.getElementById("main_navi")
      const link = navi.querySelector("a")
      navi.remove()

      link.addEventListener("click", (event) => event.preventDefault(), {
        once: true
      })
      link.dispatchEvent(
        new MouseEvent("click", { bubbles: true, cancelable: true })
      )

      expect(openConfirmDialogMock).not.toHaveBeenCalled()
    })
  })

  describe("without unsaved changes on the page", () => {
    beforeEach(() => {
      renderComponent("alchemy-main-navi", mainNavi)
    })

    it("navigates without asking", () => {
      const link = document.querySelector("alchemy-main-navi-entry > a")

      expect(clickAndCaptureCancellation(link)).toBe(false)
      expect(openConfirmDialogMock).not.toHaveBeenCalled()
    })
  })
})
