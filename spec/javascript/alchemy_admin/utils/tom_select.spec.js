import { dropdownMessages } from "alchemy_admin/utils/tom_select"

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
