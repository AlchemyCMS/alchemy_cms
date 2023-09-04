import "alchemy_admin/components/overlay"

describe("alchemy-overlay", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let overlay = undefined
  let overlayText = undefined

  const renderComponent = (html = `<alchemy-overlay></alchemy-overlay>`) => {
    document.body.innerHTML = html
    overlay = document.querySelector("alchemy-overlay")
    overlayText = document.getElementById("overlay_text")
  }

  it("should render the overlay", () => {
    renderComponent()
    expect(overlayText).toBeTruthy()
  })

  it("should be hidden", () => {
    renderComponent()
    expect(overlay.style.getPropertyValue("display")).toBe("none")
  })

  it("should have a given text", () => {
    renderComponent(`<alchemy-overlay text="Foo Bar"></alchemy-overlay>`)
    expect(overlayText.textContent).toBe("Foo Bar")
  })

  it("should be visible", () => {
    renderComponent(`<alchemy-overlay show="true"></alchemy-overlay>`)
    expect(overlay.style.getPropertyValue("display")).toBe("block")
  })
})
