import "alchemy_admin/components/dialog_link"
import { renderComponent } from "./component.helper"
import { Dialog } from "alchemy_admin/dialog"

describe("alchemy-dialog-link", () => {
  it("opens a dialog on click", () => {
    const html = `
      <a type="submit" is="alchemy-dialog-link">Open Dialog</a>
    `
    Dialog.prototype.open = jest.fn(() => Promise.resolve())
    const dialogLink = renderComponent("alchemy-dialog-link", html)
    const click = new Event("click", { bubbles: true })

    dialogLink.dispatchEvent(click)
    expect(Dialog.prototype.open).toHaveBeenCalled()
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
