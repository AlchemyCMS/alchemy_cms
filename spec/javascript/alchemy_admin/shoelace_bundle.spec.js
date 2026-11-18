import "vendor/shoelace.min.js"

describe("Shoelace bundle", () => {
  // Components we create ourselves must be registered by the bundle. Shoelace
  // registers dependencies only once a component that needs them is created.
  it("registers sl-spinner", () => {
    expect(customElements.get("sl-spinner")).toBeDefined()
  })
})
