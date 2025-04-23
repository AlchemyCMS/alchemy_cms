import { renderComponent } from "./component.helper"
import "alchemy_admin/components/update_check"

// Mock Spinner to avoid actual DOM manipulation
jest.mock("alchemy_admin/spinner")

describe("alchemy-update-check", () => {
  let component
  const html = `
    <alchemy-update-check url="/update_check">
      <div class="update_available hidden"></div>
      <div class="up_to_date hidden"></div>
      <div class="error hidden"></div>
    </alchemy-update-check>
  `

  beforeEach(() => {
    // Mock fetch globally
    global.fetch = jest.fn()

    jest.spyOn(console, "error").mockImplementation(() => {}) // Mock console.error
  })

  afterEach(() => {
    document.body.innerHTML = ""
    jest.clearAllMocks()
  })

  it("shows update available when response is 'true'", async () => {
    global.fetch.mockResolvedValueOnce({
      ok: true,
      text: () => Promise.resolve("true")
    })

    component = renderComponent("alchemy-update-check", html)
    await new Promise(process.nextTick)

    expect(
      component.querySelector(".update_available").classList.contains("hidden")
    ).toBe(false)
    expect(
      component.querySelector(".up_to_date").classList.contains("hidden")
    ).toBe(true)
    expect(component.querySelector(".error").classList.contains("hidden")).toBe(
      true
    )
  })

  it("shows update available when response is 'false'", async () => {
    global.fetch.mockResolvedValueOnce({
      ok: true,
      text: () => Promise.resolve("false")
    })

    component = renderComponent("alchemy-update-check", html)
    await new Promise(process.nextTick)

    expect(
      component.querySelector(".update_available").classList.contains("hidden")
    ).toBe(true)
    expect(
      component.querySelector(".up_to_date").classList.contains("hidden")
    ).toBe(false)
    expect(component.querySelector(".error").classList.contains("hidden")).toBe(
      true
    )
  })

  it("shows error when fetch fails", async () => {
    fetch.mockRejectedValueOnce(new Error("Network error"))

    component = renderComponent("alchemy-update-check", html)
    await new Promise(process.nextTick)

    expect(
      component.querySelector(".update_available").classList.contains("hidden")
    ).toBe(true)
    expect(
      component.querySelector(".up_to_date").classList.contains("hidden")
    ).toBe(true)
    expect(component.querySelector(".error").classList.contains("hidden")).toBe(
      false
    )
    expect(console.error).toHaveBeenCalledWith(
      "[alchemy] Error fetching update status",
      expect.any(Error)
    )
  })

  it("shows error when response is not ok", async () => {
    fetch.mockResolvedValueOnce({
      ok: false,
      text: () => Promise.resolve("Error")
    })

    component = renderComponent("alchemy-update-check", html)
    await new Promise(process.nextTick)

    expect(
      component.querySelector(".update_available").classList.contains("hidden")
    ).toBe(true)
    expect(
      component.querySelector(".up_to_date").classList.contains("hidden")
    ).toBe(true)
    expect(component.querySelector(".error").classList.contains("hidden")).toBe(
      false
    )
    expect(console.error).toHaveBeenCalledWith(
      "[alchemy] Error fetching update status",
      expect.any(Object)
    )
  })
})
