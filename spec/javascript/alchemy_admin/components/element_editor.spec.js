import ImageLoader from "alchemy_admin/image_loader"
import fileEditors from "alchemy_admin/file_editors"
import pictureEditors from "alchemy_admin/picture_editors"
import IngredientAnchorLink from "alchemy_admin/ingredient_anchor_link"
import { ElementEditor } from "alchemy_admin/components/element_editor"
import { renderComponent } from "./component.helper"
import { growl } from "alchemy_admin/growler"

jest.mock("alchemy_admin/growler", () => {
  return {
    growl: jest.fn()
  }
})

jest.mock("alchemy_admin/image_loader", () => {
  return {
    __esModule: true,
    default: {
      init: jest.fn()
    }
  }
})

jest.mock("alchemy_admin/file_editors", () => {
  return {
    __esModule: true,
    default: jest.fn()
  }
})

jest.mock("alchemy_admin/picture_editors", () => {
  return {
    __esModule: true,
    default: jest.fn()
  }
})

jest.mock("alchemy_admin/ingredient_anchor_link", () => {
  return {
    __esModule: true,
    default: { updateIcon: jest.fn() }
  }
})

jest.mock("alchemy_admin/utils/ajax", () => {
  return {
    __esModule: true,
    post(url) {
      return new Promise((resolve, reject) => {
        switch (url) {
          case "/admin/elements/123/collapse":
            resolve({
              data: {
                nestedElementIds: ["666"]
              }
            })
            break
          case "/admin/elements/123/expand":
            resolve({
              data: {
                parentElementIds: ["456"]
              }
            })
            break
          case "/admin/elements/456/expand":
            resolve({
              data: {
                parentElementIds: []
              }
            })
            break
          case "/admin/elements/666/collapse":
          case "/admin/elements/666/expand":
            reject(new Error("Something went wrong!"))
            break
          default:
            reject(new Error(`URL ${url} not found!`))
        }
      })
    }
  }
})

function getComponent(html) {
  return renderComponent("alchemy-element-editor", html)
}

describe("alchemy-element-editor", () => {
  let html = `
    <alchemy-element-editor
      id="element_123"
      data-element-id="123"
      data-element-name="article"
      class="expanded"
    >
      <div class="element-header">
        <div class="preview_text_quote">Lorem ipsum</div>
        <button class="element-toggle">
          <alchemy-icon name="expand"></alchemy-icon>
        </button>
      </div>
      <form class="element-body">
        <div class="element_errors">
          <ul class="error-messages"></ul>
        </div>
        <div class="element-ingredient-editors"></div>
      </form>
      <div class="element-footer"></div>
    </alchemy-element-editor>
  `
  let editor

  beforeEach(() => {
    editor = getComponent(html)
    Alchemy = {
      Spinner: jest.fn(() => {
        return {
          spin: jest.fn(),
          stop: jest.fn()
        }
      }),
      growl: jest.fn(),
      routes: {
        collapse_admin_element_path(id) {
          return `/admin/elements/${id}/collapse`
        },
        expand_admin_element_path(id) {
          return `/admin/elements/${id}/expand`
        }
      },
      PreviewWindow: {
        postMessage: jest.fn(),
        refresh: jest.fn()
      }
    }
    Alchemy.PreviewWindow.postMessage.mockClear()
    Alchemy.PreviewWindow.refresh.mockClear()
    growl.mockClear()
  })

  describe("connectedCallback", () => {
    beforeEach(() => {
      ImageLoader.init.mockClear()
      fileEditors.mockClear()
      pictureEditors.mockClear()
    })

    describe("if dragged", () => {
      it("does not initializes", () => {
        const html = `
          <alchemy-element-editor id="element_123" class="ui-sortable-placeholder"></alchemy-element-editor>
        `
        getComponent(html)
        expect(ImageLoader.init).not.toHaveBeenCalled()
      })
    })

    it("initializes image loader", () => {
      getComponent(html)
      expect(ImageLoader.init).toHaveBeenCalled()
    })

    it("initializes file editors", () => {
      getComponent(html)
      expect(fileEditors).toHaveBeenCalled()
    })

    it("initializes picture editors", () => {
      getComponent(html)
      expect(pictureEditors).toHaveBeenCalled()
    })
  })

  describe("on click", () => {
    it("marks element editor as selected", () => {
      return new Promise((resolve) => {
        const click = new Event("click", { bubbles: true })
        editor.dispatchEvent(click)
        window.requestAnimationFrame(() => {
          expect(editor.classList.contains("selected")).toBeTruthy()
          resolve()
        })
      })
    })

    it("focuses element in preview", () => {
      const click = new Event("click", { bubbles: true })
      const postMessage = jest.fn()
      jest.spyOn(editor, "previewWindow", "get").mockImplementation(() => {
        return {
          postMessage
        }
      })
      editor.dispatchEvent(click)
      expect(postMessage).toHaveBeenCalledWith({
        message: "Alchemy.focusElement",
        element_id: "123"
      })
    })
  })

  describe("on doubleclick", () => {
    it("toggles element", () => {
      const dblclick = new Event("dblclick", { bubbles: true })
      const originalToggle = ElementEditor.prototype.toggle
      ElementEditor.prototype.toggle = jest.fn()
      editor.header.dispatchEvent(dblclick)
      expect(ElementEditor.prototype.toggle).toHaveBeenCalled()
      ElementEditor.prototype.toggle = originalToggle
    })
  })

  describe("on click on toggle button", () => {
    it("toggles element", () => {
      const click = new Event("click", { bubbles: true })
      const originalToggle = ElementEditor.prototype.toggle
      ElementEditor.prototype.toggle = jest.fn()
      editor.toggleButton.dispatchEvent(click)
      expect(ElementEditor.prototype.toggle).toHaveBeenCalled()
      ElementEditor.prototype.toggle = originalToggle
    })
  })

  describe("if editor has nested elements", () => {
    beforeEach(() => {
      editor = getComponent(`
        <alchemy-element-editor id="element_456" data-element-id="456" class="folded">
          <div class="element-header">
            <div class="preview_text_quote">Lorem Ipsum</div>
          </div>
          <div class="nested-elements">
            <alchemy-element-editor id="element_123" data-element-id="123"></alchemy-element-editor>
          </div>
        </alchemy-element-editor>
      `)
    })

    describe("on alchemy:element-update-title", () => {
      it("updates title if triggered on first child", () => {
        const childElement = editor.querySelector("#element_123")
        const event = new CustomEvent("alchemy:element-update-title", {
          detail: { title: "New Title" },
          bubbles: true
        })
        childElement.dispatchEvent(event)
        expect(
          editor.querySelector(".element-header .preview_text_quote")
            .textContent
        ).toBe("New Title")
      })
    })
  })

  describe("on ajax:success", () => {
    describe("if event was triggered on this element", () => {
      it("sets element to saved state", () => {
        const event = new CustomEvent("ajax:success", {
          bubbles: true,
          detail: [{ ingredientAnchors: [] }]
        })
        editor.dirty = true
        editor.body.dispatchEvent(event)
        expect(editor.dirty).toBeFalsy()
      })
    })

    describe("if event was triggered on child element", () => {
      it("does not set parent element to saved", () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_456" data-element-id="456" class="expanded">
            <div class="element-header">
              <div class="preview_text_quote">Lorem Ipsum</div>
            </div>
            <div class="nested-elements">
              <alchemy-element-editor id="element_123" data-element-id="123" class="expanded">
              </alchemy-element-editor>
              <alchemy-element-editor id="element_789" data-element-id="789" class="dirty">
                <div class="element-header">
                  <div class="preview_text_quote">Child Lorem ipsum</div>
                </div>
                <form class="element-body">
                  <div class="element_errors">
                    <ul class="error-messages"></ul>
                  </div>
                </form>
              </alchemy-element-editor>
            </div>
          </alchemy-element-editor>
        `)
        const event = new CustomEvent("ajax:success", {
          bubbles: true,
          detail: [{ previewText: "Child Element", ingredientAnchors: [] }]
        })
        const childElement = editor.querySelector("#element_789")
        childElement.dirty = true
        childElement.body.dispatchEvent(event)
        expect(
          editor.header.querySelector(".preview_text_quote").textContent
        ).toBe("Lorem Ipsum")
        expect(childElement.dirty).toBeFalsy()
      })
    })
  })

  describe("on change", () => {
    describe("of inputs or selects", () => {
      it("sets element to dirty state", () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_123" class="expanded">
            <form class="element-body">
              <div class="element-ingredient-editors">
                <input type="text">
              </div>
            </form>
            <div class="element-footer"></div>
          </alchemy-element-editor>
        `)
        const event = new Event("change", { bubbles: true })
        editor.dirty = false
        editor.querySelector("input").dispatchEvent(event)
        expect(editor.dirty).toBeTruthy()
      })
    })

    describe("of nestable elements", () => {
      it("does not set element to dirty state", () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_123" class="expanded">
            <form class="element-body">
              <div class="element-ingredient-editors">
                <input type="text">
              </div>
            </form>
            <div class="nested-elements"></div>
          </alchemy-element-editor>
        `)
        const event = new Event("change", { bubbles: true })
        editor.dirty = false
        editor.querySelector(".nested-elements").dispatchEvent(event)
        expect(editor.dirty).toBeFalsy()
      })
    })
  })

  describe("focusElement", () => {
    describe("if tabs are present", () => {
      it("selects tab for element", async () => {
        editor = getComponent(`
          <sl-tab-group id="fixed-elements">
            <sl-tab slot="nav" panel="main-content-elements">
              Main Content
            </sl-tab>
            <sl-tab-panel name="main-content-elements">
              <alchemy-element-editor id="element_123"></alchemy-element-editor>
            </sl-tab-panel>
          </sl-tab-group>
        `)
        const originalSelectTab = ElementEditor.prototype.selectTabForElement
        ElementEditor.prototype.selectTabForElement = jest.fn()
        await editor.focusElement()
        expect(ElementEditor.prototype.selectTabForElement).toHaveBeenCalled()
        ElementEditor.prototype.selectTabForElement = originalSelectTab
      })
    })

    describe("if element is collapsed", () => {
      it("expands element", async () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_123" class="folded"></alchemy-element-editor>
        `)
        const originalExpand = ElementEditor.prototype.expand
        ElementEditor.prototype.expand = jest.fn()
        await editor.focusElement()
        expect(ElementEditor.prototype.expand).toHaveBeenCalled()
        ElementEditor.prototype.expand = originalExpand
      })
    })

    it("marks element as selected", async () => {
      const originalSelect = ElementEditor.prototype.selectElement
      ElementEditor.prototype.selectElement = jest.fn()
      await editor.focusElement()
      expect(ElementEditor.prototype.selectElement).toHaveBeenCalledWith(true)
      ElementEditor.prototype.selectElement = originalSelect
    })
  })

  describe("onSaveElement", () => {
    describe("if response is successful", () => {
      beforeEach(() => {
        editor = getComponent(`
          <alchemy-element-editor
            id="element_123"
            data-element-id="123"
          >
            <div class="element-header">
              <div class="preview_text_quote">Lorem ipsum</div>
            </div>
            <form class="element-body">
              <div class="element_errors">
                <ul class="error-messages">
                  <li>Please enter a value</li>
                </ul>
              </div>
              <div class="element-ingredient-editors">
                <div class="ingredient-editor validation_failed" data-ingredient-id="666"></div>
              </div>
            </form>
            <div class="element-footer"></div>
          </alchemy-element-editor>
        `)
        const data = {
          notice: "Element saved",
          ingredientAnchors: [{ ingredientId: 55, active: true }]
        }
        editor.dirty = true
        editor.onSaveElement(data)
      })

      it("sets element clean", () => {
        expect(editor.dirty).toBeFalsy
      })

      it("resets validation errors", () => {
        expect(editor.errorsDisplay.innerHTML).toBe("")
      })

      it("hides element errors", () => {
        expect(editor.elementErrors.classList).toContain("hidden")
      })

      it("removes ingredient invalid state", () => {
        expect(
          editor.querySelector(`[data-ingredient-id="666"]`).classList
        ).not.toContain("validation_failed")
      })

      it("updates ingredient anchors icon", () => {
        expect(IngredientAnchorLink.updateIcon).toHaveBeenCalledWith(55, true)
      })

      it("growls success", () => {
        expect(growl).toHaveBeenCalledWith("Element saved")
      })
    })

    describe("if response has validation errors", () => {
      beforeEach(() => {
        editor = getComponent(`
          <alchemy-element-editor
            id="element_123"
            data-element-id="123"
          >
            <form class="element-body">
              <div class="element_errors">
                <ul class="error-messages"></ul>
              </div>
              <div class="element-ingredient-editors">
                <div class="ingredient-editor" data-ingredient-id="666"></div>
              </div>
            </form>
            <div class="element-footer"></div>
          </alchemy-element-editor>
        `)
        const data = {
          warning: "Something is not right",
          errors: ["Please enter a value"],
          ingredientsWithErrors: [666]
        }
        editor.onSaveElement(data)
      })

      it("displays errors", () => {
        expect(editor.errorsDisplay.querySelector("li").textContent).toBe(
          "Please enter a value"
        )
      })

      it("marks ingredients as invalid", () => {
        expect(
          editor.querySelector(`[data-ingredient-id="666"]`).classList
        ).toContain("validation_failed")
      })

      it("growls a warning", () => {
        expect(growl).toHaveBeenCalledWith("Something is not right", "warn")
      })
    })
  })

  describe("scrollToElement", () => {
    it("scrolls to element", () => {
      ElementEditor.prototype.scrollIntoView = jest.fn()
      editor.scrollToElement()

      return new Promise((resolve) => {
        setTimeout(() => {
          expect(editor.scrollIntoView).toHaveBeenCalledWith({
            behavior: "smooth"
          })
          resolve()
        }, 50)
      })
    })
  })

  describe("selectElement", () => {
    it("marks all other element editors as unselected", () => {
      const editor = getComponent(`
        <alchemy-element-editor id="element_123"></alchemy-element-editor>
        <alchemy-element-editor id="element_666" class="selected"></alchemy-element-editor>
      `)
      editor.selectElement()
      const el = document.querySelector("#element_666")
      expect(el.classList.contains("selected")).toBeFalsy()
    })

    it("marks element editor as selected", () => {
      return new Promise((resolve) => {
        editor.selectElement()
        window.requestAnimationFrame(() => {
          expect(editor.classList.contains("selected")).toBeTruthy()
          resolve()
        })
      })
    })

    describe("with scroll enabled", () => {
      it("scrolls to element", () => {
        const scrollSpy = jest.spyOn(editor, "scrollToElement")
        editor.selectElement(true)
        expect(scrollSpy).toHaveBeenCalled()
      })
    })
  })

  describe("selectTabForElement", () => {
    describe("if tabs are not present", () => {
      it("rejects with error", async () => {
        await editor.selectTabForElement().catch((error) => {
          expect(error.message).toBe("No tabs present")
        })
      })
    })

    describe("if tabs are present", () => {
      it("selects tab", async () => {
        editor = getComponent(`
          <sl-tab-group id="fixed-elements">
            <sl-tab slot="nav" panel="main-content-elements">
              Main Content
            </sl-tab>
            <sl-tab-panel name="main-content-elements">
              <alchemy-element-editor id="element_123"></alchemy-element-editor>
            </sl-tab-panel>
          </sl-tab-group>
        `)
        const tabgroup = document.querySelector("sl-tab-group")
        tabgroup.show = jest.fn()
        await editor.selectTabForElement().then(() => {
          expect(tabgroup.show).toHaveBeenCalledWith("main-content-elements")
        })
      })
    })
  })

  describe("setClean", () => {
    beforeEach(() => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="dirty">
          <form class="element-body">
            <div class="element-ingredient-editors">
              <div class="ingredient-editor dirty"></div>
            </div>
          </form>
        </alchemy-element-editor>
      `)
      editor.setClean()
    })

    it("sets dirty to false", () => {
      expect(editor.dirty).toBeFalsy()
    })

    it("removes beforeunload", () => {
      expect(window.onbeforeunload).toBeNull()
    })

    it("sets all ingredient editors clean", () => {
      editor.body.querySelectorAll(".ingredient-editor").forEach((el) => {
        expect(el.classList.contains("dirty")).toBeFalsy()
      })
    })
  })

  describe("setDirty", () => {
    describe("if element has ingredient editors", () => {
      beforeEach(() => {
        editor = getComponent(`
          <alchemy-element-editor id="element_123" class="expanded">
            <form class="element-body">
              <div class="element-ingredient-editors">
                <input type="text">
              </div>
            </form>
            <div class="nested-elements"></div>
          </alchemy-element-editor>
        `)
      })

      it("sets dirty to true", () => {
        editor.setDirty()
        expect(editor.dirty).toBeTruthy
      })

      it("sets beforeunload", () => {
        editor.setDirty()
        expect(window.onbeforeunload).toBeInstanceOf(Function)
      })
    })
  })

  describe("setTitle", () => {
    it("sets title", () => {
      editor.setTitle("Foo bar")
      expect(
        editor.querySelector(".element-header .preview_text_quote").textContent
      ).toBe("Foo bar")
    })
  })

  describe("toggle", () => {
    describe("if collapsed", () => {
      it("expands element", async () => {
        const editor = getComponent(`
          <alchemy-element-editor id="element_123" class="folded"></alchemy-element-editor>
        `)
        originalExpand = ElementEditor.prototype.expand
        ElementEditor.prototype.expand = jest.fn()
        await editor.toggle()
        expect(editor.expand).toHaveBeenCalled()
        ElementEditor.prototype.expand = originalExpand
      })
    })

    describe("if expanded", () => {
      it("collapses element", async () => {
        const editor = getComponent(html)
        originalCollapse = ElementEditor.prototype.collapse
        ElementEditor.prototype.collapse = jest.fn()
        await editor.toggle()
        expect(editor.collapse).toHaveBeenCalled()
        ElementEditor.prototype.collapse = originalCollapse
      })
    })
  })

  describe("collapse", () => {
    describe("if collapsed", () => {
      it("immediatly resolves promise", async () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_123" class="folded"></alchemy-element-editor>
        `)
        await expect(editor.collapse()).resolves.toBe(
          "Element is already collapsed."
        )
      })
    })

    describe("if compact", () => {
      it("immediatly resolves promise", async () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_123" class="expanded" compact=""></alchemy-element-editor>
        `)
        await expect(editor.collapse()).resolves.toBe(
          "Element is already collapsed."
        )
      })
    })

    describe("if fixed", () => {
      it("immediatly resolves promise", async () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_123" class="expanded" fixed=""></alchemy-element-editor>
        `)
        await expect(editor.collapse()).resolves.toBe(
          "Element is already collapsed."
        )
      })
    })

    describe("if expanded", () => {
      it("collapses element on API then sets to collapsed", async () => {
        await editor.collapse().then(() => {
          expect(editor.collapsed).toBeTruthy()
        })
      })

      it("collapses nested elements", async () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_123" data-element-id="123" class="expanded">
            <div class="nested-elements">
              <alchemy-element-editor id="element_666" class="expanded"></alchemy-element-editor>
            </div>
          </alchemy-element-editor>
        `)
        const nestedElement = document.querySelector("#element_666")
        await editor.collapse().then(() => {
          expect(nestedElement.collapsed).toBeTruthy()
        })
      })

      it("handles errors", async () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_666" data-element-id="666" class="expanded"></alchemy-element-editor>
        `)
        global.console = {
          ...console,
          error: jest.fn()
        }
        await editor.collapse()
        expect(growl).toHaveBeenCalledWith("Something went wrong!", "error")
      })
    })
  })

  describe("expand", () => {
    describe("if expanded", () => {
      it("immediatly resolves promise", async () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_123" class="expanded"></alchemy-element-editor>
        `)
        await expect(editor.expand()).resolves.toBe(
          "Element is already expanded."
        )
      })
    })

    describe("if compact", () => {
      describe("and has a parent element editor", () => {
        it("expands parent element", async () => {
          editor = getComponent(`
            <alchemy-element-editor id="element_456" data-element-id="456" class="folded">
              <div class="nested-elements">
                <alchemy-element-editor id="element_123" data-element-id="123" class="expanded" compact=""></alchemy-element-editor>
              </div>
            </alchemy-element-editor>
          `)
          const nestedElement = document.querySelector("#element_123")
          await nestedElement.expand()
          expect(editor.expanded).toBeTruthy()
        })
      })
    })

    describe("if collapsed", () => {
      it("expands element on API then sets to expanded", async () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_456" data-element-id="456" class="folded"></alchemy-element-editor>
        `)
        await editor.expand().then(() => {
          expect(editor.expanded).toBeTruthy()
        })
      })

      it("expands parent elements", async () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_456" data-element-id="456" class="folded">
            <div class="nested-elements">
              <alchemy-element-editor id="element_123" data-element-id="123" class="folded"></alchemy-element-editor>
            </div>
          </alchemy-element-editor>
        `)
        const nestedElement = document.querySelector("#element_123")
        await nestedElement.expand().then(() => {
          expect(editor.expanded).toBeTruthy()
        })
      })

      it("handles errors", async () => {
        editor = getComponent(`
          <alchemy-element-editor id="element_666" data-element-id="666" class="folded"></alchemy-element-editor>
        `)
        global.console = {
          ...console,
          error: jest.fn()
        }
        try {
          await editor.expand()
        } catch {
          expect(growl).toHaveBeenCalledWith("Something went wrong!", "error")
        }
      })
    })
  })

  describe("updateTitle", () => {
    it("sets title", () => {
      editor.updateTitle("Foo bar")
      expect(
        editor.querySelector(".element-header .preview_text_quote").textContent
      ).toBe("Foo bar")
    })

    it("dispatches event", () => {
      return new Promise((resolve) => {
        editor.addEventListener("alchemy:element-update-title", (event) => {
          expect(event.detail).toEqual({ title: "Foo bar" })
          resolve()
        })
        editor.updateTitle("Foo bar")
      })
    })
  })

  describe("elementId", () => {
    it("returns element database id", () => {
      expect(editor.elementId).toEqual("123")
    })
  })

  describe("elementName", () => {
    it("returns element definition name", () => {
      expect(editor.elementName).toEqual("article")
    })
  })

  describe("compact", () => {
    it("is false if not has compact attribute", () => {
      expect(editor.compact).toBeFalsy()
    })

    it("is true if has compact attribute", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" compact=""></alchemy-element-editor>
      `)
      expect(editor.compact).toBeTruthy()
    })
  })

  describe("fixed", () => {
    it("is false if not has fixed attribute", () => {
      expect(editor.fixed).toBeFalsy()
    })

    it("is true if has fixed attribute", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" fixed=""></alchemy-element-editor>
      `)
      expect(editor.fixed).toBeTruthy()
    })
  })

  describe("expanded", () => {
    it("is true if not folded", () => {
      expect(editor.expanded).toBeTruthy()
    })

    it("is false if folded", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="folded"></alchemy-element-editor>
      `)
      expect(editor.expanded).toBeFalsy()
    })
  })

  describe("collapsed", () => {
    it("is true if folded", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="folded"></alchemy-element-editor>
      `)
      expect(editor.collapsed).toBeTruthy()
    })

    it("is false if not folded", () => {
      expect(editor.collapsed).toBeFalsy()
    })
  })

  describe("dirty", () => {
    it("is true if dirty class is present", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="dirty"></alchemy-element-editor>
      `)
      expect(editor.dirty).toBeTruthy()
    })

    it("is false if dirty class is not present", () => {
      expect(editor.dirty).toBeFalsy()
    })
  })

  describe("dirty =", () => {
    it("sets to dirty if set to true", () => {
      expect(editor.dirty).toBeFalsy()
      editor.dirty = true
      expect(editor.dirty).toBeTruthy()
    })

    it("sets not dirty if set to false", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="dirty"></alchemy-element-editor>
      `)
      expect(editor.dirty).toBeTruthy()
      editor.dirty = false
      expect(editor.dirty).toBeFalsy()
    })
  })

  describe("header", () => {
    it("returns header element", () => {
      expect(editor.header).toBeInstanceOf(HTMLElement)
    })
  })

  describe("body", () => {
    it("returns body", () => {
      expect(editor.body).toBeInstanceOf(HTMLElement)
    })

    it("only returns immediate body", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="expanded">
          <div class="nested-elements">
            <alchemy-element-editor id="element_666" class="expanded">
              <form class="element-body"></form>
            </alchemy-element-editor>
          </div>
        </alchemy-element-editor>
      `)
      expect(editor.body).toBeNull()
    })
  })

  describe("footer", () => {
    it("returns footer", () => {
      expect(editor.footer).toBeInstanceOf(HTMLElement)
    })

    it("only returns immediate footer", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="expanded">
          <div class="nested-elements">
            <alchemy-element-editor id="element_666" class="expanded">
              <div class="element-footer"></div>
            </alchemy-element-editor>
          </div>
        </alchemy-element-editor>
      `)
      expect(editor.footer).toBeNull()
    })
  })

  describe("toggleButton", () => {
    it("returns toggleButton", () => {
      expect(editor.toggleButton).toBeInstanceOf(HTMLElement)
    })
  })

  describe("toggleIcon", () => {
    it("returns icon if present", () => {
      expect(editor.toggleIcon).toBeInstanceOf(HTMLElement)
    })

    it("returns undefined if not present", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="expanded" compact>
          <div class="element-header"></div>
        </alchemy-element-editor>
      `)
      expect(editor.toggleIcon).toBeUndefined()
    })
  })

  describe("errorsDisplay", () => {
    it("returns errors display element", () => {
      expect(editor.errorsDisplay).toBeInstanceOf(HTMLElement)
    })
  })

  describe("elementErrors", () => {
    it("returns element errors element", () => {
      expect(editor.elementErrors).toBeInstanceOf(HTMLElement)
    })
  })

  describe("hasEditors", () => {
    it("returns true if ingredient editors present", () => {
      expect(editor.hasEditors).toBeTruthy()
    })

    it("returns false if no ingredient editors present", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="expanded"></alchemy-element-editor>
      `)
      expect(editor.hasEditors).toBeFalsy()
    })
  })

  describe("hasChildren", () => {
    it("returns true if nested elements present", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="expanded">
          <div class="nested-elements"></div>
        </alchemy-element-editor>
      `)
      expect(editor.hasChildren).toBeTruthy()
    })

    it("returns false if no ingredient editors present", () => {
      expect(editor.hasChildren).toBeFalsy()
    })
  })

  describe("firstChild", () => {
    it("returns first nested element", () => {
      editor = getComponent(`
        <alchemy-element-editor id="element_123" class="expanded">
          <div class="nested-elements">
            <alchemy-element-editor id="element_666" class="expanded"></alchemy-element-editor>
          </div>
        </alchemy-element-editor>
      `)
      expect(editor.firstChild).toBeInstanceOf(ElementEditor)
    })
  })

  describe("parentElementEditor", () => {
    it("returns parent element editor", () => {
      getComponent(`
        <alchemy-element-editor id="element_123" class="expanded">
          <div class="nested-elements">
            <alchemy-element-editor id="element_666" class="expanded"></alchemy-element-editor>
          </div>
        </alchemy-element-editor>
      `)
      editor = document.querySelector("#element_666")
      expect(editor.parentElementEditor).toBeInstanceOf(ElementEditor)
      expect(editor.parentElementEditor.id).toBe("element_123")
    })
  })
})
