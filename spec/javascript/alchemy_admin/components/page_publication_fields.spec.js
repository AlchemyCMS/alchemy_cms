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
    const html = `
      <alchemy-page-publication-fields>
        <input type="checkbox" id="page_public">
        <div class="page-publication-date-fields hidden">
          <input type="text" id="page_public_on">
          <input type="text" id="page_public_until">
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

    // Mock flatpickr instance on the public_on field
    publicOnField._flatpickr = {
      setDate: vi.fn()
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
      expect(publicOnField._flatpickr.setDate).toHaveBeenCalled()
      const calledWith = publicOnField._flatpickr.setDate.mock.calls[0][0]
      expect(calledWith).toBeInstanceOf(Date)
    })

    it("clears the public_until field", () => {
      publicUntilField.value = "2025-12-31"
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
      expect(publicUntilField.value).toEqual("")
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

    it("clears the public_on field value", () => {
      expect(publicOnField.value).toEqual("")
    })

    it("clears the public_until field value", () => {
      expect(publicUntilField.value).toEqual("")
    })

    it("does not call flatpickr setDate", () => {
      expect(publicOnField._flatpickr.setDate).not.toHaveBeenCalled()
    })
  })

  describe("when public checkbox is missing", () => {
    it("does not throw an error", () => {
      const html = `
        <alchemy-page-publication-fields>
          <div class="page-publication-date-fields hidden">
            <input type="text" id="page_public_on">
            <input type="text" id="page_public_until">
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
      expect(publicOnField._flatpickr.setDate).toHaveBeenCalledTimes(1)

      // Uncheck
      publicCheckbox.checked = false
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
      expect(publicationDateFields.classList.contains("hidden")).toBeTruthy()
      expect(publicOnField.value).toEqual("")

      // Check again
      publicCheckbox.checked = true
      publicCheckbox.dispatchEvent(new Event("click", { bubbles: true }))
      expect(publicationDateFields.classList.contains("hidden")).toBeFalsy()
      expect(publicOnField._flatpickr.setDate).toHaveBeenCalledTimes(2)
    })
  })
})
