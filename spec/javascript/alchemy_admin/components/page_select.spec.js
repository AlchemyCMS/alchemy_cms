import { renderComponent } from "./component.helper"
import "alchemy_admin/components/page_select"

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

    it("should initialize Tom Select", () => {
      expect(component.getElementsByClassName("ts-wrapper").length).toEqual(1)
    })

    it("should not show a clear button", () => {
      expect(component.querySelector(".clear-button")).toBeNull()
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

  describe("preselection", () => {
    // A page the user cannot edit is serialized without site/language_code, so the
    // selection can carry partial data. The rich option template renders it
    // null-safe, so preselection must not crash and must still mark the field as
    // having a selected item.
    const selection = { id: 42, name: "Index", url_path: "/index" }

    beforeEach(() => {
      const html = `
        <alchemy-page-select placeholder="Search page" selection='${JSON.stringify(selection)}'>
          <input type="text">
        </alchemy-page-select>
      `
      component = renderComponent("alchemy-page-select", html)
    })

    it("shows the selected item", () => {
      expect(
        component.querySelector(".ts-control .item").textContent
      ).toContain("Index")
    })

    it("marks the field as having a selected item", () => {
      expect(
        component.querySelector(".ts-wrapper").classList.contains("has-items")
      ).toBe(true)
    })

    it("submits the selected id", () => {
      // The page editor renders the page id into the input, which is what gets
      // submitted with the form.
      const html = `
        <alchemy-page-select placeholder="Search page" selection='${JSON.stringify(selection)}'>
          <input type="text" value="42">
        </alchemy-page-select>
      `
      component = renderComponent("alchemy-page-select", html)
      expect(component.querySelector("input.tomselected").value).toEqual("42")
    })

    it("does not dispatch a change event for the preselection", () => {
      const listener = vi.fn()
      const html = `
        <alchemy-page-select placeholder="Search page" selection='${JSON.stringify(selection)}'>
          <input type="text">
        </alchemy-page-select>
      `
      const el = document.createElement("div")
      el.addEventListener("Alchemy.RemoteSelect.Change", listener)
      document.body.appendChild(el)
      el.innerHTML = html
      expect(listener).not.toHaveBeenCalled()
      el.remove()
    })

    // The link dialog renders a URL (page path + anchor) into this input and
    // reads it back on submit. Tom Select must not turn it into a stray option
    // or overwrite it with the selected id.
    it("keeps a non-id input value (e.g. a link url) untouched", () => {
      const html = `
        <alchemy-page-select placeholder="Search page" selection='${JSON.stringify(selection)}'>
          <input type="text" value="/index#start">
        </alchemy-page-select>
      `
      component = renderComponent("alchemy-page-select", html)
      expect(
        component.querySelector(".ts-control .item").textContent
      ).toContain("Index")
      expect(component.querySelector("input.tomselected").value).toEqual(
        "/index#start"
      )
    })
  })

  describe("selecting a page", () => {
    // Tom Select keeps its own bookkeeping on an option, among it the node it
    // was rendered into. Serializing that into the selection attribute breaks
    // the render cache once a component is attached to it again.
    it("stores the record without the Tom Select internals", () => {
      const html = `
        <alchemy-page-select placeholder="Search page">
          <input type="text">
        </alchemy-page-select>
      `
      component = renderComponent("alchemy-page-select", html)
      const tomSelect = component.getElementsByTagName("input")[0].tomselect
      tomSelect.addOption({ id: 42, name: "Index", url_path: "/index" })
      tomSelect.addItem("42")

      const selection = JSON.parse(component.getAttribute("selection"))
      expect(selection).toEqual({ id: 42, name: "Index", url_path: "/index" })
      expect(
        Object.keys(selection).filter((key) => key.startsWith("$"))
      ).toEqual([])
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
