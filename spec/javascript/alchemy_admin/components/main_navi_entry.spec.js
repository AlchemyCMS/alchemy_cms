import { vi } from "vitest"

// Mock Floating UI so we can assert how the entry positions its flyout without
// relying on a real layout (jsdom reports zeroed geometry).
const { computePositionMock, autoUpdateMock, stopMock } = vi.hoisted(() => {
  return {
    computePositionMock: vi.fn().mockResolvedValue({ x: 48, y: 120 }),
    stopMock: vi.fn(),
    autoUpdateMock: vi.fn((reference, floating, update) => {
      update()
      return stopMock
    })
  }
})

vi.mock("@floating-ui/dom", () => ({
  computePosition: computePositionMock,
  autoUpdate: autoUpdateMock,
  flip: vi.fn(() => ({}))
}))

import { renderComponent } from "./component.helper"
import "alchemy_admin/components/main_navi_entry"

// Wait for the microtask that applies the computed position.
const flushPromises = () => new Promise((resolve) => setTimeout(resolve))

const withSubNavigation = `
  <alchemy-main-navi-entry class="main_navi_entry has_sub_navigation">
    <a href="/admin"><label>Pages</label></a>
    <div class="sub_navigation" style="position: fixed">
      <div class="subnavi_tab"><a href="/admin/pages">Pages</a></div>
    </div>
  </alchemy-main-navi-entry>
`

const labelOnly = `
  <alchemy-main-navi-entry class="main_navi_entry">
    <a href="/admin/users"><label style="position: absolute">Users</label></a>
  </alchemy-main-navi-entry>
`

const inFlow = `
  <alchemy-main-navi-entry class="main_navi_entry">
    <a href="/admin/dashboard"><label>Dashboard</label></a>
  </alchemy-main-navi-entry>
`

describe("alchemy-main-navi-entry", () => {
  beforeEach(() => {
    computePositionMock.mockClear()
    autoUpdateMock.mockClear()
    stopMock.mockClear()
  })

  it("fixes the sub navigation flyout to the viewport on hover", async () => {
    const entry = renderComponent("alchemy-main-navi-entry", withSubNavigation)
    entry.dispatchEvent(new MouseEvent("mouseenter"))
    await flushPromises()

    const flyout = entry.querySelector(".sub_navigation")
    expect(computePositionMock).toHaveBeenCalledWith(
      entry,
      flyout,
      expect.objectContaining({ strategy: "fixed", placement: "right-start" })
    )
    expect(flyout.style.position).toEqual("fixed")
    expect(flyout.style.left).toEqual("48px")
    expect(flyout.style.top).toEqual("120px")
  })

  it("falls back to the label when the entry has no sub navigation", async () => {
    const entry = renderComponent("alchemy-main-navi-entry", labelOnly)
    entry.dispatchEvent(new MouseEvent("mouseenter"))
    await flushPromises()

    const flyout = entry.querySelector("label")
    expect(computePositionMock).toHaveBeenCalledWith(
      entry,
      flyout,
      expect.anything()
    )
    expect(flyout.style.position).toEqual("fixed")
  })

  it("leaves an in-flow flyout untouched", async () => {
    const entry = renderComponent("alchemy-main-navi-entry", inFlow)
    entry.dispatchEvent(new MouseEvent("mouseenter"))
    await flushPromises()

    expect(computePositionMock).not.toHaveBeenCalled()
    expect(entry.querySelector("label").style.position).toEqual("")
  })

  it("resets the flyout and stops updating on mouseleave", async () => {
    const entry = renderComponent("alchemy-main-navi-entry", withSubNavigation)
    entry.dispatchEvent(new MouseEvent("mouseenter"))
    await flushPromises()

    entry.dispatchEvent(new MouseEvent("mouseleave"))

    const flyout = entry.querySelector(".sub_navigation")
    expect(stopMock).toHaveBeenCalled()
    expect(flyout.style.position).toEqual("")
    expect(flyout.style.left).toEqual("")
    expect(flyout.style.top).toEqual("")
  })
})
