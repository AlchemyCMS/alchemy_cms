import "alchemy_admin/components/icon"
import { renderComponent } from "./component.helper"

describe("alchemy-icon", () => {
  it("renders an icon with default style", () => {
    const html = `
      <link rel="preload" href="/assets/remixicon.symbol.svg" as="image">
      <alchemy-icon name="image"></alchemy-icon>
    `
    const icon = renderComponent("alchemy-icon", html)

    expect(icon.innerHTML).toEqual(
      '<svg class="icon"><use href="/assets/remixicon.symbol.svg#ri-image-line"></use></svg>'
    )
  })

  it("renders an icon with given style", () => {
    const html = `
      <link rel="preload" href="/assets/remixicon.symbol.svg" as="image">
      <alchemy-icon name="image" icon-style="fill"></alchemy-icon>
    `
    const icon = renderComponent("alchemy-icon", html)

    expect(icon.innerHTML).toEqual(
      '<svg class="icon"><use href="/assets/remixicon.symbol.svg#ri-image-fill"></use></svg>'
    )
  })

  it("renders an icon with no style", () => {
    const html = `
      <link rel="preload" href="/assets/remixicon.symbol.svg" as="image">
      <alchemy-icon name="image" icon-style="none"></alchemy-icon>
    `
    const icon = renderComponent("alchemy-icon", html)

    expect(icon.innerHTML).toEqual(
      '<svg class="icon"><use href="/assets/remixicon.symbol.svg#ri-image"></use></svg>'
    )
  })

  it("renders an icon with size", () => {
    const html = `
      <link rel="preload" href="/assets/remixicon.symbol.svg" as="image">
      <alchemy-icon name="image" size="medium"></alchemy-icon>
    `
    const icon = renderComponent("alchemy-icon", html)

    expect(icon.innerHTML).toEqual(
      '<svg class="icon icon--medium"><use href="/assets/remixicon.symbol.svg#ri-image-line"></use></svg>'
    )
  })
})
