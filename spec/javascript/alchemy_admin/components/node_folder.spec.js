import { describe, it, expect, beforeEach, afterEach } from "vitest"
import "alchemy_admin/components/node_folder"

describe("AlchemyNodeFolder", () => {
  let container

  const render = (html) => {
    container.innerHTML = html
    return container.querySelector("alchemy-node-folder")
  }

  beforeEach(() => {
    container = document.createElement("div")
    document.body.appendChild(container)
  })

  afterEach(() => {
    document.body.removeChild(container)
  })

  it("renders a folder button", () => {
    const element = render("<alchemy-node-folder></alchemy-node-folder>")

    expect(element.querySelector("button.node_folder")).toBeTruthy()
  })

  it("renders a down arrow when unfolded", () => {
    const element = render("<alchemy-node-folder></alchemy-node-folder>")

    expect(element.querySelector("alchemy-icon").getAttribute("name")).toBe(
      "arrow-down-s"
    )
  })

  it("renders a right arrow when folded", () => {
    const element = render("<alchemy-node-folder folded></alchemy-node-folder>")

    expect(element.querySelector("alchemy-icon").getAttribute("name")).toBe(
      "arrow-right-s"
    )
  })

  it("updates the arrow when the folded attribute is set", () => {
    const element = render("<alchemy-node-folder></alchemy-node-folder>")

    element.toggleAttribute("folded", true)

    expect(element.querySelector("alchemy-icon").getAttribute("name")).toBe(
      "arrow-right-s"
    )
  })

  it("updates the arrow when the folded attribute is removed", () => {
    const element = render("<alchemy-node-folder folded></alchemy-node-folder>")

    element.toggleAttribute("folded", false)

    expect(element.querySelector("alchemy-icon").getAttribute("name")).toBe(
      "arrow-down-s"
    )
  })
})
