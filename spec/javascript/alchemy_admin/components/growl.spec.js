import "alchemy_admin/components/growl"
import { renderComponent } from "./component.helper"

describe("alchemy-growl", () => {
  it("should have the given message from attribute", () => {
    const html = `
      <div id="flash_notices"></div>
      <alchemy-growl message="Foo Bar"></alchemy-growl>
    `
    renderComponent("alchemy-growl", html)
    const message = document.querySelector("alchemy-message")
    expect(message.textContent).toMatch("Foo Bar")
  })

  it("should have the given message from innerHTML", () => {
    const html = `
      <div id="flash_notices"></div>
      <alchemy-growl>Foo Bar</alchemy-growl>
    `
    renderComponent("alchemy-growl", html)
    const message = document.querySelector("alchemy-message")
    expect(message.textContent).toMatch("Foo Bar")
  })

  it("removes element from DOM after connect", () => {
    const html = `
      <div id="flash_notices"></div>
      <alchemy-growl>Foo Bar</alchemy-growl>
    `
    renderComponent("alchemy-growl", html)
    expect(document.querySelector("alchemy-growl")).toBeNull()
  })
})
