import { vi } from "vitest"
import { LinkDialog } from "alchemy_admin/link_dialog"

vi.mock("alchemy_admin/spinner")
vi.mock("alchemy_admin/hotkeys")

describe("LinkDialog", () => {
  beforeEach(() => {
    document.body.innerHTML = ""
    Alchemy.routes.link_admin_pages_path = "/admin/pages/link"
  })

  /**
   * Helper to create a LinkDialog, inject form HTML, and submit the internal form.
   * Returns the promise that resolves with the link data on form submission.
   */
  function submitInternalForm(internalLinkValue, anchorValue) {
    const dialog = new LinkDialog({
      url: internalLinkValue,
      type: "internal"
    })

    const promise = dialog.open()

    // Build the form HTML that the server would render
    const formHtml = `
      <div data-link-form-type="internal">
        <input id="internal_link" value="${internalLinkValue}" />
        <select id="element_anchor">
          <option value="">None</option>
          ${anchorValue ? `<option value="${anchorValue}" selected>${anchorValue}</option>` : ""}
        </select>
        <input id="internal_link_title" value="" />
        <select id="internal_link_target"><option value="">Default</option></select>
        <alchemy-dom-id-api-select></alchemy-dom-id-api-select>
      </div>
      <div data-link-form-type="file">
        <alchemy-attachment-select></alchemy-attachment-select>
        <input id="file_link" value="" />
        <input id="file_link_title" value="" />
        <select id="file_link_target"><option value="">Default</option></select>
      </div>
    `

    // replace() injects HTML into dialog body and attaches event listeners
    dialog.replace(formHtml)

    // Submit the internal form
    const form = document.querySelector('[data-link-form-type="internal"]')
    form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }))

    return promise
  }

  describe("submitting an internal link with anchor", () => {
    it("strips anchor with hyphens before appending new anchor", async () => {
      const result = await submitInternalForm("/page#my-section", "#new-section")
      expect(result.url).toBe("/page#new-section")
    })

    it("does not create double hash when anchor contains hyphens", async () => {
      const result = await submitInternalForm("/page#my-section", "#my-section")
      expect(result.url).toBe("/page#my-section")
    })

    it("strips simple word-only anchors correctly", async () => {
      const result = await submitInternalForm("/page#section", "#other")
      expect(result.url).toBe("/page#other")
    })

    it("handles url without existing anchor", async () => {
      const result = await submitInternalForm("/page", "#section")
      expect(result.url).toBe("/page#section")
    })
  })
})
