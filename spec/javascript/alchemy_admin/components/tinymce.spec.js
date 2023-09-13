import { renderComponent } from "./component.helper"
import "../../../../app/javascript/alchemy_admin/components/tinymce"
import "../../../../vendor/assets/javascripts/tinymce/tinymce.min"
import { mockIntersectionObserver } from "jsdom-testing-mocks"

describe("alchemy-tinymce", () => {
  const intersectionObserver = mockIntersectionObserver()
  /**
   *
   * @type {HTMLElement | undefined}
   */
  let component = undefined

  const textareaId = "tinymce-textarea"

  beforeAll(() => {
    window.Alchemy = {
      locale: "en_US"
    }
  })

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

    it("should have an tinymce container after the intersection observer triggered", () => {
      expect(component.getElementsByClassName("mce-tinymce").length).toEqual(0)
      intersectionObserver.enterNode(component)
      expect(component.getElementsByClassName("mce-tinymce").length).toEqual(1)
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
      expect(component.configuration.locale).toEqual("en_US")
    })

    it("should add the attributes to configuration and cast dashes with underscores", () => {
      expect(component.configuration.toolbar).toEqual("bold italic")
      expect(component.configuration.foo_bar).toEqual("bar | foo")
    })

    it("should use these configuration for the tinymce", () => {
      intersectionObserver.enterNode(component)
      const tinymceSettings = tinymce.get(textareaId).settings
      expect(tinymceSettings.id).toEqual(textareaId)
      expect(tinymceSettings.toolbar).toEqual("bold italic")
    })
  })
})
