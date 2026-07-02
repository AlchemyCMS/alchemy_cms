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
})
