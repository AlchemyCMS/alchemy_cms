import { renderComponent } from "./component.helper"
import "alchemy_admin/components/sortable_element"

function getComponent(html) {
  return renderComponent("alchemy-sortable-element", html)
}

describe("alchemy-sortable-element", () => {
  describe("elementId", () => {
    it("returns the element-id attribute", () => {
      const el = getComponent(
        `<alchemy-sortable-element element-id="123"></alchemy-sortable-element>`
      )
      expect(el.elementId).toBe("123")
    })

    it("returns null when attribute is missing", () => {
      const el = getComponent(
        `<alchemy-sortable-element></alchemy-sortable-element>`
      )
      expect(el.elementId).toBeNull()
    })
  })

  describe("elementName", () => {
    it("returns the element-name attribute", () => {
      const el = getComponent(
        `<alchemy-sortable-element element-name="article"></alchemy-sortable-element>`
      )
      expect(el.elementName).toBe("article")
    })

    it("returns null when attribute is missing", () => {
      const el = getComponent(
        `<alchemy-sortable-element></alchemy-sortable-element>`
      )
      expect(el.elementName).toBeNull()
    })
  })

  describe("elementEditor", () => {
    it("returns the nested alchemy-element-editor", () => {
      const el = getComponent(`
        <alchemy-sortable-element element-id="123" element-name="article">
          <alchemy-element-editor id="element_123"></alchemy-element-editor>
        </alchemy-sortable-element>
      `)
      expect(el.elementEditor).not.toBeNull()
      expect(el.elementEditor.tagName.toLowerCase()).toBe(
        "alchemy-element-editor"
      )
      expect(el.elementEditor.id).toBe("element_123")
    })

    it("returns null when no element-editor is nested", () => {
      const el = getComponent(
        `<alchemy-sortable-element element-id="123"></alchemy-sortable-element>`
      )
      expect(el.elementEditor).toBeNull()
    })
  })
})
