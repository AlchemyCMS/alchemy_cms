import "alchemy_admin/components/char_counter"
import { renderComponent, setupLanguage } from "./component.helper"

describe("alchemy-char-counter", () => {
  /**
   *
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  const input = () => {
    return component.getElementsByTagName("input")[0]
  }

  const small = () => {
    return component.getElementsByTagName("small")[0]
  }

  beforeEach(() => {
    setupLanguage()

    const html = `
      <alchemy-char-counter>
        <input type="text">
      </alchemy-char-counter>
    `

    component = renderComponent("alchemy-char-counter", html)
  })

  it("should render the input field", () => {
    expect(input()).toBeInstanceOf(HTMLElement)
  })

  it("should create typed character indicator", () => {
    expect(small().textContent).toEqual("0 of 60 chars")
  })

  it("should have a default max character count of 60", () => {
    expect(component.maxChars).toEqual(60)
  })

  describe("with maxChar", () => {
    beforeEach(() => {
      const html = `
        <alchemy-char-counter max-chars="123">
          <input type="text">
        </alchemy-char-counter>
      `

      component = renderComponent("alchemy-char-counter", html)
    })

    it("should create typed character indicator", () => {
      expect(small().textContent).toEqual("0 of 123 chars")
    })
  })
})
