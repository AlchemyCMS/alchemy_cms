import { renderComponent } from "./component.helper"

import "alchemy_admin/components/tags_autocomplete"

describe("alchemy-tags-autocomplete", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined
  /**
   * @type {HTMLInputElement | undefined}
   */
  let input = undefined

  beforeEach(() => {
    const html = `
      <alchemy-tags-autocomplete placeholder="Search tag" url="/admin/tags/autocomplete">
        <input type="text" name="element[tag_list]" value="foo,bar">
      </alchemy-tags-autocomplete>
    `
    component = renderComponent("alchemy-tags-autocomplete", html)
    input = component.getElementsByTagName("input")[0]
  })

  it("enhances the input with Tom Select", () => {
    expect(document.querySelector(".ts-wrapper")).toBeInstanceOf(HTMLElement)
  })

  it("adds the autocomplete_tag_list class", () => {
    expect(component.classList.contains("autocomplete_tag_list")).toBe(true)
  })

  it("pre-populates the tags from the comma-separated value", () => {
    const items = document.querySelectorAll(".ts-control .item")
    expect(Array.from(items).map((item) => item.dataset.value)).toEqual([
      "foo",
      "bar"
    ])
  })

  it("uses the wrapper's placeholder", () => {
    expect(input.tomselect.control_input.getAttribute("placeholder")).toBe(
      "Search tag"
    )
  })

  it("syncs created tags back to the input as a comma-separated value", () => {
    input.tomselect.createItem("baz")
    expect(input.value).toBe("foo,bar,baz")
  })

  it("clears the typed text after a tag is selected", () => {
    const tomSelect = input.tomselect
    tomSelect.addOption({ id: "zwei", text: "zwei" })
    tomSelect.setTextboxValue("zwei")
    tomSelect.addItem("zwei")
    expect(tomSelect.control_input.value).toBe("")
  })

  describe("create option gating", () => {
    let createFilter = undefined

    beforeEach(() => {
      createFilter = input.tomselect.settings.createFilter
    })

    it("hides the create option while suggestions are loading", () => {
      const context = {
        loading: 1,
        options: {},
        settings: { duplicates: false }
      }
      expect(createFilter.call(context, "eins")).toBe(false)
    })

    it("offers the create option when idle and the tag does not exist", () => {
      const context = {
        loading: 0,
        options: {},
        settings: { duplicates: false }
      }
      expect(createFilter.call(context, "eins")).toBe(true)
    })

    it("hides the create option when the tag already exists", () => {
      const context = {
        loading: 0,
        options: { eins: {} },
        settings: { duplicates: false }
      }
      expect(createFilter.call(context, "eins")).toBe(false)
    })
  })
})
