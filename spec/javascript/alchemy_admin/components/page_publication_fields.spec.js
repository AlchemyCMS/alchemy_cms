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

  let publicOnPicker = undefined
  let publicUntilPicker = undefined

  beforeEach(() => {
    const html = `
      <alchemy-page-publication-fields>
        <input type="checkbox" id="page_public">
        <div class="page-publication-date-fields hidden">
          <alchemy-datepicker>
            <input type="text" id="page_public_on">
          </alchemy-datepicker>
          <alchemy-datepicker>
            <input type="text" id="page_public_until">
          </alchemy-datepicker>
        </div>
      </alchemy-page-publication-fields>
    `
    component = renderComponent("alchemy-page-publication-fields", html)
    publicCheckbox = component.querySelector("#page_public")
    publicOnField = component.querySelector("#page_public_on")
    publicUntilField = component.querySelector("#page_public_until")
    publicOnPicker = component.querySelector(
      "alchemy-datepicker:has(#page_public_on)"
    )
    publicUntilPicker = component.querySelector(
      "alchemy-datepicker:has(#page_public_until)"
    )
    publicationDateFields = component.querySelector(
      ".page-publication-date-fields"
    )

    // Mock flatpickr instance on the alchemy-datepicker components
    publicOnPicker.flatpickr = {
      setDate: vi.fn(),
      clear: vi.fn()
    }
    publicUntilPicker.flatpickr = {
      clear: vi.fn()
    }
  })

  describe("when public checkbox is checked", () => {
    beforeEach(() => {
      publicCheckbox.checked = true
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
    })

    it("shows the publication date fields", () => {
      expect(publicationDateFields.classList.contains("hidden")).toBeFalsy()
    })

    it("sets the public_on date to now", () => {
      expect(publicOnPicker.flatpickr.setDate).toHaveBeenCalled()
      const calledWith = publicOnPicker.flatpickr.setDate.mock.calls[0][0]
      expect(calledWith).toBeInstanceOf(Date)
    })

    it("clears the public_until field", () => {
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
      expect(publicUntilPicker.flatpickr.clear).toHaveBeenCalled()
    })
  })

  describe("when public checkbox is unchecked", () => {
    beforeEach(() => {
      publicCheckbox.checked = false
      publicationDateFields.classList.remove("hidden")
      publicOnField.value = "2025-01-01"
      publicUntilField.value = "2025-12-31"
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
    })

    it("hides the publication date fields", () => {
      expect(publicationDateFields.classList.contains("hidden")).toBeTruthy()
    })

    it("clears the public_on field via flatpickr", () => {
      expect(publicOnPicker.flatpickr.clear).toHaveBeenCalled()
    })

    it("clears the public_until field via flatpickr", () => {
      expect(publicUntilPicker.flatpickr.clear).toHaveBeenCalled()
    })

    it("does not call flatpickr setDate", () => {
      expect(publicOnPicker.flatpickr.setDate).not.toHaveBeenCalled()
    })
  })

  describe("when public checkbox is missing", () => {
    it("does not throw an error", () => {
      const html = `
        <alchemy-page-publication-fields>
          <div class="page-publication-date-fields hidden">
            <alchemy-datepicker>
              <input type="text" id="page_public_on">
            </alchemy-datepicker>
            <alchemy-datepicker>
              <input type="text" id="page_public_until">
            </alchemy-datepicker>
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
      expect(publicOnPicker.flatpickr.setDate).toHaveBeenCalledTimes(1)

      // Uncheck
      publicCheckbox.checked = false
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
      expect(publicationDateFields.classList.contains("hidden")).toBeTruthy()
      expect(publicOnPicker.flatpickr.clear).toHaveBeenCalledTimes(1)

      // Check again
      publicCheckbox.checked = true
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
      expect(publicationDateFields.classList.contains("hidden")).toBeFalsy()
      expect(publicOnPicker.flatpickr.setDate).toHaveBeenCalledTimes(2)
    })
  })
})
