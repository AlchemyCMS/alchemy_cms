import "alchemy_admin/components/spinner"

describe("alchemy-spinner", () => {
  /**
   * @type {HTMLElement | undefined}
   */
  let spinner = undefined
  /**
   * @type {SVGElement | undefined}
   */
  let svg = undefined

  const renderComponent = (html = `<alchemy-spinner></alchemy-spinner>`) => {
    document.body.innerHTML = html
    spinner = document.querySelector("alchemy-spinner")
    svg = spinner.querySelector("svg")
  }

  it("should render a spinner SVG", async () => {
    renderComponent()
    expect(svg).toBeTruthy()
  })

  it("should have a size class", async () => {
    renderComponent()
    expect(spinner.classList.contains("spinner--medium")).toBeTruthy()
    expect(spinner.size).toBe("medium")
  })

  it("should have a color custom property", async () => {
    renderComponent()
    expect(svg.style.getPropertyValue("--spinner-color")).toBe("currentColor")
    expect(spinner.color).toBe("currentColor")
  })

  it("should support other sizes", async () => {
    renderComponent(`<alchemy-spinner size="large"></alchemy-spinner>`)
    expect(spinner.size).toBe("large")
  })

  it("should support other colors", async () => {
    renderComponent(`<alchemy-spinner color="pink"></alchemy-spinner>`)
    expect(spinner.color).toBe("pink")
  })
})
