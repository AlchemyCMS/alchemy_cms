import { Dialog } from "alchemy_admin/dialog"

// load all shoelace components
import "vendor/shoelace.min"

// also provide jQuery $ - function
import jQuery from "jquery"
globalThis.$ = jQuery

describe("Dialog", () => {
  it("should have default options", () => {
    const dialog = new Dialog()

    expect(dialog.options).toEqual({
      title: "",
      size: "300x400",
      padding: true
    })
  })

  it("is possible to change the default options", () => {
    const dialog = new Dialog("http://foo.bar", {
      size: "800x600",
      title: "Foo"
    })

    expect(dialog.options).toEqual({
      title: "Foo",
      size: "800x600",
      padding: true
    })
  })

  describe("close", () => {
    let dialog, promise

    beforeEach(() => {
      dialog = new Dialog("http://foo.bar")
      promise = dialog.open()
    })

    describe("on hide", () => {
      const hide = () => {
        // the hide - event can't be used because of a weird error, that the getAnimations - method
        // is not available. We are going to mock the event instead.
        document
          .querySelector("sl-dialog")
          .dispatchEvent(new CustomEvent("sl-after-hide"))
      }

      it("should remove the component", () => {
        promise.catch(() => {})
        hide()
        expect(document.querySelector("sl-dialog")).toBeNull()
      })

      it("should reject the promise", () => {
        hide()
        return expect(promise).rejects.toBeUndefined()
      })
    })

    describe("on submit", () => {
      const submit = (callback = undefined) => {
        document.querySelector("sl-dialog").hide = () => Promise.resolve()
        dialog.onSubmitSuccess(callback)
        return new Promise((resolve) => {
          setTimeout(() => resolve())
        })
      }

      it("should remove the dialog", async () => {
        await submit()
        expect(document.querySelector("sl-dialog")).toBeNull()
      })

      it("should resolve the promise on submit", async () => {
        await submit()
        return expect(promise).resolves.toBeUndefined()
      })

      it("calls the callback if given", async () => {
        const callback = jest.fn()
        await submit(callback)
        expect(callback).toBeCalled()
      })
    })
  })

  /**
   * Jest is weird and the open block is before the close block it will break during runs,
   * but with this order the test succeed all the time.
   */
  describe("open", () => {
    let dialog, dialogComponent

    beforeEach(() => {
      dialog = new Dialog("http://foo.bar")
      dialog.open()
      dialogComponent = document.querySelector("sl-dialog")
    })

    it("shows a sl-dialog - component", () => {
      expect(dialogComponent).toBeInstanceOf(HTMLElement)
      expect(dialogComponent.open).toBeTruthy()
    })

    it("loads the given url", () => {
      expect(
        document.querySelector("alchemy-remote-partial").getAttribute("url")
      ).toEqual("http://foo.bar")
    })
  })
})
