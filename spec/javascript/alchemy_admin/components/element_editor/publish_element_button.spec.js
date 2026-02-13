import { vi } from "vitest"
import "alchemy_admin/components/element_editor/publish_element_button"
import { renderComponent } from "../component.helper"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import { growl } from "alchemy_admin/growler"

vi.mock("alchemy_admin/components/preview_window", () => {
  return {
    reloadPreview: vi.fn()
  }
})

vi.mock("alchemy_admin/growler", () => {
  return {
    growl: vi.fn()
  }
})

vi.mock("alchemy_admin/utils/ajax", () => {
  return {
    __esModule: true,
    patch(url) {
      return new Promise((resolve, reject) => {
        switch (url) {
          case "/admin/elements/123/publish":
            resolve({
              data: {
                public: false,
                tooltip: "Show element"
              }
            })
            break
          case "/admin/elements/666/publish":
            reject(new Error("Something went wrong!"))
            break
          default:
            reject(new Error(`URL ${url} not found!`))
        }
      })
    }
  }
})

describe("alchemy-publish-element-button", () => {
  let html = `
    <alchemy-element-editor>
      <span class="element-hidden-icon"></span>
      <div class="element-toolbar">
        <alchemy-publish-element-button>
          <sl-button-group>
            <sl-tooltip content="Hide element">
              <sl-button type="submit" variant="default" outline>Hide</sl-button>
            </sl-tooltip>
            <sl-tooltip content="Schedule element">
              <sl-button href="/admin/elements/schedule" variant="default" outline>Schedule</sl-button>
            </sl-tooltip>
          </sl-button-group>
        </alchemy-publish-element-button>
      </div>
    </alchemy-element-editor>
  `
  let button

  beforeEach(() => {
    button = renderComponent("alchemy-publish-element-button", html)
    Alchemy = {
      routes: {
        publish_admin_element_path(id) {
          return `/admin/elements/${id}/publish`
        }
      }
    }
    reloadPreview.mockClear()
    growl.mockClear()
  })

  describe("on click of publish button", () => {
    it("Publishes element editor", () => {
      const click = new CustomEvent("click", { bubbles: true })
      const publishButton = button.querySelector("sl-button[type='submit']")
      vi.spyOn(button, "elementId", "get").mockReturnValue("123")
      publishButton.dispatchEvent(click)

      return new Promise((resolve) => {
        setTimeout(() => {
          expect(button.publishTooltip.getAttribute("content")).toEqual(
            "Show element"
          )
          expect(reloadPreview).toHaveBeenCalled()
          resolve()
        }, 1)
      })
    }, 100)

    describe("on error", () => {
      it("Shows error", () => {
        const click = new CustomEvent("click", { bubbles: true })
        const publishButton = button.querySelector("sl-button[type='submit']")
        vi.spyOn(button, "elementId", "get").mockReturnValue("666")
        publishButton.dispatchEvent(click)

        return new Promise((resolve) => {
          setTimeout(() => {
            expect(growl).toHaveBeenCalled()
            resolve()
          }, 1)
        })
      }, 100)
    })
  })
})
