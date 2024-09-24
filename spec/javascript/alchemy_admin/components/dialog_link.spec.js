import "alchemy_admin/components/dialog_link"
import { Dialog } from "alchemy_admin/dialog"
import { renderComponent } from "./component.helper"

// import jquery and append it to the window object
import jQuery from "jquery"
globalThis.$ = jQuery

describe("alchemy-dialog-link", () => {
  it("opens a dialog on click", () => {
    const html = `
      <a type="submit" is="alchemy-dialog-link">Open Dialog</a>
    `
    const openSpy = jest.spyOn(Dialog.prototype, "open")
    const dialogLink = renderComponent("alchemy-dialog-link", html)
    const click = new Event("click", { bubbles: true })

    dialogLink.dispatchEvent(click)
    expect(openSpy).toHaveBeenCalled()
  })

  it("has default dialogOptions", () => {
    const html = `
      <a is="alchemy-dialog-link">Open Dialog</a>
    `
    const dialogLink = renderComponent("alchemy-dialog-link", html)

    expect(dialogLink.dialogOptions).toEqual({})
  })

  it("parses dialogOptions from dataset", () => {
    const html = `
      <a is="alchemy-dialog-link" data-dialog-options="{&quot;title&quot;:&quot;Foo&quot;}">Open Dialog</a>
    `
    const dialogLink = renderComponent("alchemy-dialog-link", html)

    expect(dialogLink.dialogOptions.title).toEqual("Foo")
  })
})
