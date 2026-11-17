import "alchemy_admin/components/filter_panel_toggle"
import { renderComponent } from "./component.helper"

describe("alchemy-filter-panel-toggle", () => {
  let component = undefined

  beforeEach(() => {
    document.body.classList.remove("filter-panel-collapsed")
    document.cookie = "alchemy-filter-panel-collapsed=; Path=/; Max-Age=0"
    component = renderComponent(
      "alchemy-filter-panel-toggle",
      `<alchemy-filter-panel-toggle><button type="button">Toggle</button></alchemy-filter-panel-toggle>`
    )
  })

  it("collapses the filter panel on click", () => {
    component.querySelector("button").click()
    expect(document.body.classList.contains("filter-panel-collapsed")).toBe(
      true
    )
  })

  it("expands the collapsed filter panel on click", () => {
    document.body.classList.add("filter-panel-collapsed")
    component.querySelector("button").click()
    expect(document.body.classList.contains("filter-panel-collapsed")).toBe(
      false
    )
  })

  it("remembers the state in a cookie", () => {
    component.querySelector("button").click()
    expect(document.cookie).toContain("alchemy-filter-panel-collapsed=true")
    component.querySelector("button").click()
    expect(document.cookie).toContain("alchemy-filter-panel-collapsed=false")
  })
})
