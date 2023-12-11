import "alchemy_admin/components/element_editor/publish_element_button"
import { renderComponent } from "../component.helper"

jest.mock("alchemy_admin/utils/ajax", () => {
  return {
    __esModule: true,
    patch(url) {
      return new Promise((resolve, reject) => {
        switch (url) {
          case "/admin/elements/123/publish":
            resolve({
              data: {
                public: false,
                label: "Hide element"
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
      <div class="element-toolbar">
        <alchemy-publish-element-button>
          <label>Show element</label>
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
      },
      reloadPreview: jest.fn(),
      growl: jest.fn()
    }

    Alchemy.reloadPreview.mockClear()
    Alchemy.growl.mockClear()
  })

  describe("on change", () => {
    it("Publishes element editor", () => {
      const change = new CustomEvent("sl-change", { bubbles: true })
      jest.spyOn(button, "elementId", "get").mockReturnValue("123")
      button.dispatchEvent(change)

      return new Promise((resolve) => {
        setTimeout(() => {
          expect(button.label.innerText).toEqual("Hide element")
          expect(Alchemy.reloadPreview).toHaveBeenCalled()
          resolve()
        }, 1)
      })
    }, 100)
  })

  describe("on error", () => {
    it("Shows error", () => {
      const change = new CustomEvent("sl-change", { bubbles: true })
      jest.spyOn(button, "elementId", "get").mockReturnValue("666")
      button.dispatchEvent(change)

      return new Promise((resolve) => {
        setTimeout(() => {
          expect(Alchemy.growl).toHaveBeenCalled()
          resolve()
        }, 1)
      })
    }, 100)
  })
})
