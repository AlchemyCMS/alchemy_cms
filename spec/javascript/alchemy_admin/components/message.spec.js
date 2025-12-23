import { vi } from "vitest"
import "alchemy_admin/components/message"
import { renderComponent } from "./component.helper"

describe("alchemy-message", () => {
  describe("dismiss", () => {
    describe("when dismissable", () => {
      it("dismisses on click", () => {
        const html = `
          <alchemy-message dismissable>
            A message
          </alchemy-message>
        `
        const component = renderComponent("alchemy-message", html)
        const spy = vi.spyOn(component, "dismiss")
        component.dispatchEvent(new Event("click"))
        expect(spy).toHaveBeenCalled()
      })

      it("dismisses after delay", () => {
        return new Promise((resolve) => {
          const html = `
            <div id="flash_notices" data-auto-dismiss-delay="10">
              <alchemy-message dismissable>
                A message
              </alchemy-message>
            </div>
          `
          const component = renderComponent("alchemy-message", html)
          const spy = vi.spyOn(component, "dismiss")
          setTimeout(() => {
            expect(spy).toHaveBeenCalled()
            resolve()
          }, 15)
        })
      }, 100)

      it("when type error, does not dismis after delay", () => {
        return new Promise((resolve) => {
          const html = `
            <div id="flash_notices" data-auto-dismiss-delay="10">
              <alchemy-message dismissable type="error">
                A message
              </alchemy-message>
            </div>
          `
          const component = renderComponent("alchemy-message", html)
          const spy = vi.spyOn(component, "dismiss")
          setTimeout(() => {
            expect(spy).not.toHaveBeenCalled()
            resolve()
          }, 15)
        })
      }, 100)
    })

    describe("when type error", () => {
      it("dismisses on click", () => {
        const html = `
          <alchemy-message type="error">
            A message
          </alchemy-message>
        `
        const component = renderComponent("alchemy-message", html)
        const spy = vi.spyOn(component, "dismiss")
        component.dispatchEvent(new Event("click"))
        expect(spy).toHaveBeenCalled()
      })
    })

    describe("when not type error nor dismissable", () => {
      it("dismisses on click", () => {
        const html = `
          <alchemy-message type="info">
            A message
          </alchemy-message>
        `
        const component = renderComponent("alchemy-message", html)
        const spy = vi.spyOn(component, "dismiss")
        component.dispatchEvent(new Event("click"))
        expect(spy).not.toHaveBeenCalled()
      })
    })
  })

  describe("type", () => {
    describe("when message type is given", () => {
      it("is given type", () => {
        const html = `
          <alchemy-message type="warning">
            A warning message
          </alchemy-message>
        `
        const component = renderComponent("alchemy-message", html)
        expect(component.type).toEqual("warning")
      })
    })

    describe("when message type is not given", () => {
      it("is given type", () => {
        const html = `
          <alchemy-message>
            A warning message
          </alchemy-message>
        `
        const component = renderComponent("alchemy-message", html)
        expect(component.type).toEqual("notice")
      })
    })
  })

  describe("dismissable", () => {
    describe("when dismissable is set", () => {
      it("is dismissable", () => {
        const html = `
          <alchemy-message dismissable>
            A dismissable message
          </alchemy-message>
        `
        const component = renderComponent("alchemy-message", html)
        expect(component.dismissable).toBe(true)
      })

      it("and type error, it shows close icon", () => {
        const html = `
          <alchemy-message type="error" dismissable>
            A dismissable message
          </alchemy-message>
        `
        const component = renderComponent("alchemy-message", html)
        expect(
          component.querySelector("alchemy-icon[name='close']")
        ).toBeDefined()
      })
    })

    describe("when dismissable is not set", () => {
      it("is not dismissable", () => {
        const html = `
          <alchemy-message>
            A not dismissable message
          </alchemy-message>
        `
        const component = renderComponent("alchemy-message", html)
        expect(component.dismissable).toBe(false)
      })
    })
  })

  describe("iconName", () => {
    describe("when 'warning', 'warn' or 'alert' message type is given", () => {
      ;["warning", "warn", "alert"].forEach((type) => {
        it("is alert", () => {
          const html = `
            <alchemy-message type="${type}">
              A ${type} message
            </alchemy-message>
          `
          const component = renderComponent("alchemy-message", html)
          expect(component.iconName).toEqual("alert")
        })
      })
    })

    describe("when 'notice' message type is given", () => {
      const html = `
        <alchemy-message type="notice">
          A notice message
        </alchemy-message>
      `

      it("is check", () => {
        const component = renderComponent("alchemy-message", html)

        expect(component.iconName).toEqual("check")
      })
    })

    describe("when 'info' or 'hint' message type is given", () => {
      ;["hint", "info"].forEach((type) => {
        it("is alert", () => {
          const html = `
            <alchemy-message type="${type}">
              A ${type} message
            </alchemy-message>
          `
          const component = renderComponent("alchemy-message", html)
          expect(component.iconName).toEqual("information")
        })
      })
    })

    describe("when 'error' message type is given", () => {
      const html = `
        <alchemy-message type="error">
          A error message
        </alchemy-message>
      `

      it("is check", () => {
        const component = renderComponent("alchemy-message", html)

        expect(component.iconName).toEqual("bug")
      })
    })

    describe("when unknown message type is given", () => {
      const html = `
        <alchemy-message type="foo">
          A foo message
        </alchemy-message>
      `

      it("is the given message type as icon name", () => {
        const component = renderComponent("alchemy-message", html)

        expect(component.iconName).toEqual("foo")
      })
    })
  })
})
