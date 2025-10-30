import { vi } from "vitest"
import "alchemy_admin/components/link_buttons/unlink_button"
import { renderComponent } from "../component.helper"

beforeEach(() => {
  Alchemy.LinkDialog = vi.fn().mockImplementation(function () {
    return { open: vi.fn() }
  })
})

describe("alchemy-unlink-button", () => {
  it("adds icon_button class", () => {
    const html = `
      <alchemy-link-buttons>
        <button is="alchemy-unlink-button">Link</button>
      </alchemy-link-buttons>
    `
    const button = renderComponent("alchemy-unlink-button", html)
    expect(button.classList).toContain("icon_button")
  })

  it("adds type button", () => {
    const html = `
      <alchemy-link-buttons>
        <button is="alchemy-unlink-button">Link</button>
      </alchemy-link-buttons>
    `
    const button = renderComponent("alchemy-unlink-button", html)
    expect(button.getAttribute("type")).toBe("button")
  })

  it("adds unlink icon", () => {
    const html = `
      <alchemy-link-buttons>
        <button is="alchemy-unlink-button">Link</button>
      </alchemy-link-buttons>
    `
    const button = renderComponent("alchemy-unlink-button", html)
    expect(
      button.querySelector('alchemy-icon[name="link-unlink"]')
    ).toBeTruthy()
  })

  it("removes link on click", () => {
    const html = `
      <alchemy-link-buttons>
        <button is="alchemy-unlink-button" class="linked">Link</button>
      </alchemy-link-buttons>
    `
    const button = renderComponent("alchemy-unlink-button", html)
    const submit = new Event("click", { bubbles: true })

    expect(button.linked).toBeTruthy()
    button.dispatchEvent(submit)
    expect(button.linked).toBeFalsy()
  })

  it("dispatches event on click", () => {
    return new Promise((resolve) => {
      const html = `
        <alchemy-link-buttons>
          <button is="alchemy-unlink-button" class="linked">Link</button>
        </alchemy-link-buttons>
      `
      const button = renderComponent("alchemy-unlink-button", html)
      button
        .closest("alchemy-link-buttons")
        .addEventListener("alchemy:unlink", (e) => {
          expect(e.type).toEqual("alchemy:unlink")
          resolve()
        })
      const click = new Event("click", { bubbles: true })
      button.dispatchEvent(click)
    })
  })

  describe("set linked", () => {
    it("adds linked class if true", () => {
      const html = `
        <alchemy-link-buttons>
          <button is="alchemy-unlink-button" class="disabled">Link</button>
        </alchemy-link-buttons>
      `
      const button = renderComponent("alchemy-unlink-button", html)

      button.linked = true
      expect(button.classList).toContain("linked")
    })

    it("removes tabindex if true", () => {
      const html = `
        <alchemy-link-buttons>
          <button is="alchemy-unlink-button" class="disabled" tabindex="-1">Link</button>
        </alchemy-link-buttons>
      `
      const button = renderComponent("alchemy-unlink-button", html)

      button.linked = true
      expect(button.getAttribute("tabindex")).toBeFalsy()
    })

    it("adds disabled class if false", () => {
      const html = `
        <alchemy-link-buttons>
          <button is="alchemy-unlink-button" class="linked">Link</button>
        </alchemy-link-buttons>
      `
      const button = renderComponent("alchemy-unlink-button", html)

      button.linked = false
      expect(button.classList).toContain("disabled")
    })

    it("adds tabindex if false", () => {
      const html = `
        <alchemy-link-buttons>
          <button is="alchemy-unlink-button" class="linked">Link</button>
        </alchemy-link-buttons>
      `
      const button = renderComponent("alchemy-unlink-button", html)

      button.linked = false
      expect(button.getAttribute("tabindex")).toEqual("-1")
    })
  })

  describe("linked", () => {
    it("returns true if has linked class", () => {
      const html = `
        <alchemy-link-buttons>
          <button is="alchemy-unlink-button" class="linked">Link</button>
        </alchemy-link-buttons>
      `
      const button = renderComponent("alchemy-unlink-button", html)

      expect(button.linked).toBeTruthy()
    })

    it("returns false if has disabled class", () => {
      const html = `
        <alchemy-link-buttons>
          <button is="alchemy-unlink-button" class="disabled">Link</button>
        </alchemy-link-buttons>
      `
      const button = renderComponent("alchemy-unlink-button", html)

      expect(button.linked).toBeFalsy()
    })
  })
})
