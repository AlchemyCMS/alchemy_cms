import { vi } from "vitest"
import {
  dropdownMessages,
  focusTomSelect,
  teardownTomSelect
} from "alchemy_admin/utils/tom_select"

describe("focusTomSelect", () => {
  it("focuses the Tom Select control when it is initialized", () => {
    const tomSelect = { focus: vi.fn() }
    const focusFallback = vi.fn()

    focusTomSelect(tomSelect, focusFallback)

    expect(tomSelect.focus).toHaveBeenCalled()
    expect(focusFallback).not.toHaveBeenCalled()
  })

  it("calls the fallback when Tom Select is not initialized", () => {
    const focusFallback = vi.fn()

    focusTomSelect(null, focusFallback)

    expect(focusFallback).toHaveBeenCalled()
  })
})

describe("teardownTomSelect", () => {
  it("closes the dropdown before destroying the instance", () => {
    const calls = []
    const tomSelect = {
      close: (setTextboxValue) => calls.push(["close", setTextboxValue]),
      destroy: () => calls.push(["destroy"])
    }

    teardownTomSelect(tomSelect)

    expect(calls).toEqual([["close", false], ["destroy"]])
  })

  it("does nothing when Tom Select is not initialized", () => {
    expect(() => teardownTomSelect(null)).not.toThrow()
  })
})

describe("dropdownMessages", () => {
  describe("option_create", () => {
    it("separates the label from the created tag name", () => {
      const html = dropdownMessages.option_create(
        { input: "eins" },
        (str) => str
      )
      expect(html).toMatch(/Add\s+<strong>eins<\/strong>/)
    })
  })

  describe("loading_more", () => {
    it("renders a translated pagination message", () => {
      expect(dropdownMessages.loading_more()).toContain("Loading more results")
    })
  })

  describe("no_more_results", () => {
    it("renders a translated end-of-list message", () => {
      expect(dropdownMessages.no_more_results()).toContain("No more results")
    })
  })
})
