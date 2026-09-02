import { renderComponent } from "./component.helper"
import "alchemy_admin/components/page_select"

const PAYLOAD = "<img src=x onerror=alert(1)>"

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

  describe("rendering", () => {
    const page = (attrs) => ({
      name: "Home",
      site: { name: "Default site" },
      url_path: "/home",
      language_code: "en",
      ...attrs
    })

    const render = (attrs, term = "") => {
      const el = document.createElement("div")
      el.innerHTML = component._renderListEntry(page(attrs), term)
      return el
    }

    beforeEach(() => {
      const html = `
        <alchemy-page-select>
          <input type="text">
        </alchemy-page-select>
      `
      component = renderComponent("alchemy-page-select", html)
    })

    it("escapes the page name", () => {
      const name = `Home ${PAYLOAD}`
      const el = render({ name }, "Home")
      expect(el.querySelector("img")).toBeNull()
      expect(
        el.querySelector(".page-select--page-name").textContent.trim()
      ).toEqual(name)
    })

    it("escapes the site name", () => {
      const el = render({ site: { name: PAYLOAD } })
      expect(el.querySelector("img")).toBeNull()
      expect(
        el.querySelector(".page-select--site-name").textContent.trim()
      ).toEqual(PAYLOAD)
    })

    it("escapes the url path", () => {
      const el = render({ url_path: PAYLOAD })
      expect(el.querySelector("img")).toBeNull()
      expect(
        el.querySelector(".page-select--page-urlname").textContent.trim()
      ).toEqual(PAYLOAD)
    })

    it("escapes the language code", () => {
      const el = render({ language_code: PAYLOAD })
      expect(el.querySelector("img")).toBeNull()
      expect(
        el.querySelector(".page-select--language-code").textContent.trim()
      ).toEqual(PAYLOAD)
    })

    it("escapes the name of the selected page", () => {
      const el = document.createElement("div")
      el.innerHTML = component._renderResult(page({ name: PAYLOAD }))
      expect(el.querySelector("img")).toBeNull()
      expect(el.textContent).toEqual(PAYLOAD)
    })
  })
})
