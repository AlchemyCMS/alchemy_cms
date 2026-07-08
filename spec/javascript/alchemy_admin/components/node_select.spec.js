import { renderComponent } from "./component.helper"

import "alchemy_admin/components/node_select"

describe("alchemy-node-select", () => {
  /**
   *
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  describe("without configuration", () => {
    beforeEach(() => {
      const html = `
        <alchemy-node-select allow-clear>
          <input type="text">
        </alchemy-node-select>
      `
      component = renderComponent("alchemy-node-select", html)
    })

    it("should render the input field", () => {
      expect(component.getElementsByTagName("input")[0]).toBeInstanceOf(
        HTMLElement
      )
    })

    it("should initialize Tom Select", () => {
      expect(component.getElementsByClassName("ts-wrapper").length).toEqual(1)
    })

    it("should allow clearing the selection", () => {
      expect(component.allowClear).toBeTruthy()
    })
  })

  describe("selection", () => {
    const selection = {
      id: 123,
      name: "Test Node",
      lft: 1,
      rgt: 2,
      url: null,
      parent_id: null,
      ancestors: []
    }

    beforeEach(() => {
      const html = `
        <alchemy-node-select selection='${JSON.stringify(selection)}'>
          <input type="text">
        </alchemy-node-select>
      `
      component = renderComponent("alchemy-node-select", html)
    })

    it("should receive selection parameter", () => {
      expect(JSON.parse(component.selection)).toEqual(selection)
    })

    it("should preselect the given item", () => {
      expect(component.querySelector(".ts-control").textContent).toContain(
        "Test Node"
      )
    })
  })

  describe("query params", () => {
    beforeEach(() => {
      const html = `
        <alchemy-node-select query-params="{&quot;foo&quot;:&quot;bar&quot;}">
          <input type="text">
        </alchemy-node-select>
      `
      component = renderComponent("alchemy-node-select", html)
    })

    it("should receive query parameter", () => {
      expect(JSON.parse(component.queryParams)).toEqual({ foo: "bar" })
    })

    it("should add the query parameter to the API call", () => {
      expect(component.ajaxConfig.data("test").filter.foo).toEqual("bar")
    })
  })
})
