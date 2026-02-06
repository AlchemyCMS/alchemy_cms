import "alchemy_admin/components/list_filter"
import { renderComponent } from "./component.helper"

describe("alchemy-list-filter", () => {
  beforeAll(() => {
    // Mock the global key function used for keyboard shortcuts
    window.key = vi.fn()
    window.key.setScope = vi.fn()
  })

  describe("with a flat list", () => {
    let component

    beforeEach(() => {
      const html = `
        <alchemy-list-filter items-selector=".item" name-attribute="name">
          <input type="text">
          <button type="button">Clear</button>
        </alchemy-list-filter>
        <ul>
          <li class="item" name="Apple">Apple</li>
          <li class="item" name="Banana">Banana</li>
          <li class="item" name="Cherry">Cherry</li>
        </ul>
      `
      component = renderComponent("alchemy-list-filter", html)
    })

    it("shows all items when filter is empty", () => {
      component.filter("")
      const items = document.querySelectorAll(".item")
      items.forEach((item) => {
        expect(item.classList.contains("hidden")).toBe(false)
      })
    })

    it("filters items by name", () => {
      component.filter("ban")
      expect(
        document.querySelector('[name="Apple"]').classList.contains("hidden")
      ).toBe(true)
      expect(
        document.querySelector('[name="Banana"]').classList.contains("hidden")
      ).toBe(false)
      expect(
        document.querySelector('[name="Cherry"]').classList.contains("hidden")
      ).toBe(true)
    })

    it("filters case-insensitively", () => {
      component.filter("APPLE")
      expect(
        document.querySelector('[name="Apple"]').classList.contains("hidden")
      ).toBe(false)
    })

    it("clears the filter", () => {
      component.filter("ban")
      component.clear()
      expect(component.filterField.value).toBe("")
      const items = document.querySelectorAll(".item")
      items.forEach((item) => {
        expect(item.classList.contains("hidden")).toBe(false)
      })
    })
  })

  describe("with nested items", () => {
    let component

    beforeEach(() => {
      const html = `
        <alchemy-list-filter items-selector=".element" name-attribute="display-name">
          <input type="text">
          <button type="button">Clear</button>
        </alchemy-list-filter>
        <div class="element" display-name="Parent A">
          <div class="nested">
            <div class="element" display-name="Parent A > Child 1">Child 1</div>
            <div class="element" display-name="Parent A > Child 2">Child 2</div>
          </div>
        </div>
        <div class="element" display-name="Parent B">
          <div class="nested">
            <div class="element" display-name="Parent B > Child 3">Child 3</div>
          </div>
        </div>
      `
      component = renderComponent("alchemy-list-filter", html)
    })

    it("keeps parent visible when child matches", () => {
      component.filter("Child 1")

      const parentA = document.querySelector('[display-name="Parent A"]')
      const child1 = document.querySelector('[display-name="Parent A > Child 1"]')
      const child2 = document.querySelector('[display-name="Parent A > Child 2"]')
      const parentB = document.querySelector('[display-name="Parent B"]')

      expect(parentA.classList.contains("hidden")).toBe(false)
      expect(child1.classList.contains("hidden")).toBe(false)
      expect(child2.classList.contains("hidden")).toBe(true)
      expect(parentB.classList.contains("hidden")).toBe(true)
    })

    it("shows parent when searching for parent name", () => {
      component.filter("Parent A")

      const parentA = document.querySelector('[display-name="Parent A"]')
      const child1 = document.querySelector('[display-name="Parent A > Child 1"]')
      const child2 = document.querySelector('[display-name="Parent A > Child 2"]')
      const parentB = document.querySelector('[display-name="Parent B"]')

      expect(parentA.classList.contains("hidden")).toBe(false)
      // Children also match because their display-name contains "Parent A"
      expect(child1.classList.contains("hidden")).toBe(false)
      expect(child2.classList.contains("hidden")).toBe(false)
      expect(parentB.classList.contains("hidden")).toBe(true)
    })

    it("shows all items when filter is cleared", () => {
      component.filter("Child 1")
      component.clear()

      const items = document.querySelectorAll(".element")
      items.forEach((item) => {
        expect(item.classList.contains("hidden")).toBe(false)
      })
    })
  })

  describe("with deeply nested items", () => {
    let component

    beforeEach(() => {
      const html = `
        <alchemy-list-filter items-selector=".element" name-attribute="display-name">
          <input type="text">
          <button type="button">Clear</button>
        </alchemy-list-filter>
        <div class="element" display-name="Level 1">
          <div class="nested">
            <div class="element" display-name="Level 1 > Level 2">
              <div class="nested">
                <div class="element" display-name="Level 1 > Level 2 > Level 3">Deep</div>
              </div>
            </div>
          </div>
        </div>
      `
      component = renderComponent("alchemy-list-filter", html)
    })

    it("keeps all ancestors visible when deeply nested item matches", () => {
      component.filter("Level 3")

      const level1 = document.querySelector('[display-name="Level 1"]')
      const level2 = document.querySelector('[display-name="Level 1 > Level 2"]')
      const level3 = document.querySelector(
        '[display-name="Level 1 > Level 2 > Level 3"]'
      )

      expect(level1.classList.contains("hidden")).toBe(false)
      expect(level2.classList.contains("hidden")).toBe(false)
      expect(level3.classList.contains("hidden")).toBe(false)
    })
  })

  describe("attributes", () => {
    it("uses 'name' as default name attribute", () => {
      const html = `
        <alchemy-list-filter items-selector=".item">
          <input type="text">
          <button type="button">Clear</button>
        </alchemy-list-filter>
      `
      const component = renderComponent("alchemy-list-filter", html)
      expect(component.nameAttribute).toBe("name")
    })

    it("uses custom name attribute when specified", () => {
      const html = `
        <alchemy-list-filter items-selector=".item" name-attribute="display-name">
          <input type="text">
          <button type="button">Clear</button>
        </alchemy-list-filter>
      `
      const component = renderComponent("alchemy-list-filter", html)
      expect(component.nameAttribute).toBe("display-name")
    })
  })
})
