import { renderComponent, setupLanguage } from "./component.helper"
import "../mocks/matchMedia.js"
import "alchemy_admin/components/tinymce"
import "vendor/tinymce.min"
import { mockIntersectionObserver } from "jsdom-testing-mocks"

describe("alchemy-tinymce", () => {
  const intersectionObserver = mockIntersectionObserver()
  /**
   *
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  const textareaId = "tinymce-textarea"

  beforeAll(() => setupLanguage())

  describe("render", () => {
    beforeEach(() => {
      const html = `
      <alchemy-tinymce>
        <textarea id="${textareaId}"></textarea>
      </alchemy-tinymce>
    `
      component = renderComponent("alchemy-tinymce", html)
    })

    it("should render the textarea field", () => {
      expect(component.getElementsByTagName("textarea")[0]).toBeInstanceOf(
        HTMLElement
      )
    })

    it.skip("should have an tinymce container after the intersection observer triggered", () => {
      expect(component.getElementsByClassName("tox-tinymce").length).toEqual(0)
      intersectionObserver.enterNode(component)
      expect(component.getElementsByClassName("tox-tinymce").length).toEqual(1)
    })

    it("should show a spinner", async () => {
      expect(component.getElementsByTagName("alchemy-spinner").length).toEqual(
        1
      )
    })
  })

  describe("configuration", () => {
    beforeEach(() => {
      const html = `
      <alchemy-tinymce toolbar="bold italic" foo-bar="bar | foo">
        <textarea id="${textareaId}"></textarea>
      </alchemy-tinymce>
    `
      component = renderComponent("alchemy-tinymce", html)
    })

    it("has a tinymce configuration", () => {
      expect(component.configuration).toBeInstanceOf(Object)
    })

    it("should have the locale", () => {
      expect(component.configuration.locale).toEqual("en")
    })

    it("should add the attributes to configuration and cast dashes with underscores", () => {
      expect(component.configuration.toolbar).toEqual("bold italic")
      expect(component.configuration.foo_bar).toEqual("bar | foo")
    })

    it("should set the selector to textarea id", () => {
      expect(component.configuration.selector).toEqual("#tinymce-textarea")
    })
  })

  describe("minHeight", () => {
    const html = `
      <alchemy-tinymce>
        <textarea id="tinymce-textarea"></textarea>
      </alchemy-tinymce>
    `

    beforeEach(() => {
      Alchemy.TinymceDefaults = {
        toolbar: ["1", "2"],
        statusbar: true,
        min_height: 220
      }
    })

    it("returns the configured min_height", () => {
      const component = renderComponent("alchemy-tinymce", html)
      expect(component.minHeight).toEqual(220)
    })
  })
})
