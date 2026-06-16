import { vi } from "vitest"
import "alchemy_admin/components/page_publication_fields"
import { renderComponent } from "./component.helper"

describe("alchemy-page-publication-fields", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let component = undefined
  let publicCheckbox = undefined
  let publicOnField = undefined
  let publicUntilField = undefined
  let publicationDateFields = undefined

  beforeEach(() => {
    // Freeze time and force a fixed timezone offset so the expected local
    // value is deterministic. -120 means UTC+2, i.e. local time is two hours
    // ahead of UTC.
    vi.useFakeTimers()
    vi.setSystemTime(new Date("2026-06-12T10:00:00Z"))
    vi.spyOn(Date.prototype, "getTimezoneOffset").mockReturnValue(-120)

    const html = `
      <alchemy-page-publication-fields>
        <input type="checkbox" id="page_public">
        <div class="page-publication-date-fields hidden">
          <input type="datetime-local" id="page_public_on">
          <input type="datetime-local" id="page_public_until">
        </div>
      </alchemy-page-publication-fields>
    `
    component = renderComponent("alchemy-page-publication-fields", html)
    publicCheckbox = component.querySelector("#page_public")
    publicOnField = component.querySelector("#page_public_on")
    publicUntilField = component.querySelector("#page_public_until")
    publicationDateFields = component.querySelector(
      ".page-publication-date-fields"
    )
  })

  afterEach(() => {
    vi.useRealTimers()
    vi.restoreAllMocks()
  })

  describe("when public checkbox is checked", () => {
    beforeEach(() => {
      publicCheckbox.checked = true
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
    })

    it("shows the publication date fields", () => {
      expect(publicationDateFields.classList.contains("hidden")).toBeFalsy()
    })

    it("sets the public_on field to the current local date and time", () => {
      // UTC time is 10:00, local time (UTC+2) is 12:00. The datetime-local
      // field must hold the local representation without a timezone suffix.
      expect(publicOnField.value).toEqual("2026-06-12T12:00")
    })

    it("clears the public_until field", () => {
      expect(publicUntilField.value).toEqual("")
    })
  })

  describe("when public checkbox is unchecked", () => {
    beforeEach(() => {
      publicCheckbox.checked = false
      publicationDateFields.classList.remove("hidden")
      publicOnField.value = "2025-01-01T00:00"
      publicUntilField.value = "2025-12-31T00:00"
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
    })

    it("hides the publication date fields", () => {
      expect(publicationDateFields.classList.contains("hidden")).toBeTruthy()
    })

    it("clears the public_on field", () => {
      expect(publicOnField.value).toEqual("")
    })

    it("clears the public_until field", () => {
      expect(publicUntilField.value).toEqual("")
    })
  })

  describe("when public checkbox is missing", () => {
    it("does not throw an error", () => {
      const html = `
        <alchemy-page-publication-fields>
          <div class="page-publication-date-fields hidden">
            <input type="datetime-local" id="page_public_on">
            <input type="datetime-local" id="page_public_until">
          </div>
        </alchemy-page-publication-fields>
      `
      expect(() => {
        renderComponent("alchemy-page-publication-fields", html)
      }).not.toThrow()
    })
  })

  describe("toggling multiple times", () => {
    it("handles repeated toggling correctly", () => {
      // First check
      publicCheckbox.checked = true
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
      expect(publicationDateFields.classList.contains("hidden")).toBeFalsy()
      expect(publicOnField.value).toEqual("2026-06-12T12:00")

      // Uncheck
      publicCheckbox.checked = false
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
      expect(publicationDateFields.classList.contains("hidden")).toBeTruthy()
      expect(publicOnField.value).toEqual("")

      // Check again
      publicCheckbox.checked = true
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
      expect(publicationDateFields.classList.contains("hidden")).toBeFalsy()
      expect(publicOnField.value).toEqual("2026-06-12T12:00")
    })
  })
})
