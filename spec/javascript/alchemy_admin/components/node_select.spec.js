import { renderComponent } from "./component.helper"

// import jquery and append it to the window object
import jQuery from "jquery"
globalThis.$ = jQuery
globalThis.jQuery = jQuery

import "alchemy_admin/components/node_select"
import("vendor/jquery_plugins/select2")

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

    it("should initialize Select2", () => {
      expect(
        component.getElementsByClassName("select2-container").length
      ).toEqual(1)
    })

    it("should show a remove 'button'", () => {
      expect(component.select2Config.allowClear).toBeTruthy()
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

    it("should add the selection parameter to the select2 config", async () => {
      return new Promise((resolve) => {
        component.select2Config.initSelection(null, (json) => {
          expect(json).toEqual(selection)
          resolve()
        })
      })
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
      expect(component.ajaxConfig.data("test").q.foo).toEqual("bar")
    })
  })
})
