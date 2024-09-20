import { renderComponent } from "./component.helper"

// import jquery and append it to the window object
import jQuery from "jquery"
globalThis.$ = jQuery
globalThis.jQuery = jQuery

import "alchemy_admin/components/page_select"
import("select2")

describe("alchemy-page-select", () => {
  /**
   *
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  describe("without configuration", () => {
    beforeEach(() => {
      const html = `
        <alchemy-page-select>
          <input type="text">
        </alchemy-page-select>
      `
      component = renderComponent("alchemy-page-select", html)
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

    it("should not show a remove 'button'", () => {
      expect(
        document.querySelector(".select2-container.select2-allowclear")
      ).toBeNull()
    })
  })

  describe("allow clear", () => {
    beforeEach(() => {
      const html = `
        <alchemy-page-select allow-clear>
          <input type="text">
        </alchemy-page-select>
      `
      component = renderComponent("alchemy-page-select", html)
    })

    it("should show a remove 'button'", () => {
      expect(component.allowClear).toBeTruthy()
    })
  })

  describe("query params", () => {
    beforeEach(() => {
      const html = `
        <alchemy-page-select query-params="{&quot;foo&quot;:&quot;bar&quot;}">
          <input type="text">
        </alchemy-page-select>
      `
      component = renderComponent("alchemy-page-select", html)
    })

    it("should receive query parameter", () => {
      expect(JSON.parse(component.queryParams)).toEqual({ foo: "bar" })
    })

    it("should add the query parameter to the API call", () => {
      expect(component.ajaxConfig.data("test").q.foo).toEqual("bar")
    })
  })
})
