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

  beforeAll(() => {
    setupLanguage()
    // The tinymce configuration is set in the global Alchemy object
    // because we translate the configuration from the Rails backend
    // into the JS world.
    Alchemy.TinymceDefaults = {
      skin: "alchemy",
      icons: "remixicons",
      width: "auto",
      resize: true,
      min_height: 250,
      menubar: false,
      statusbar: true,
      toolbar: [
        "bold italic underline | strikethrough subscript superscript | numlist bullist indent outdent | removeformat | fullscreen",
        "pastetext charmap hr | undo redo | alchemy_link unlink anchor | code"
      ],
      fix_list_elements: true,
      convert_urls: false,
      entity_encoding: "raw",
      paste_as_text: true,
      element_format: "html",
      branding: false,
      license_key: "gpl"
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

    it("should have an tinymce container after the intersection observer triggered", async () => {
      expect(component.getElementsByClassName("tox-tinymce").length).toEqual(0)
      intersectionObserver.enterNode(component)
      await new Promise(process.nextTick)
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

    it("should have the language", () => {
      expect(component.configuration.language).toEqual("en")
    })

    it("should add the attributes to configuration and cast dashes with underscores", () => {
      expect(component.configuration.toolbar).toEqual("bold italic")
      expect(component.configuration.foo_bar).toEqual("bar | foo")
    })

    it("should handle boolean HTML attributes", () => {
      const html = `
        <alchemy-tinymce readonly="readonly">
          <textarea id="${textareaId}"></textarea>
        </alchemy-tinymce>
      `
      component = renderComponent("alchemy-tinymce", html)
      expect(component.configuration.readonly).toEqual(true)
    })

    it("should set the selector to textarea id", () => {
      expect(component.configuration.selector).toEqual("#tinymce-textarea")
    })

    it("sets height to min_height from defaults", () => {
      expect(component.configuration.height).toEqual(250)
    })

    describe("if min-height is set on component", () => {
      it("uses that value for height", () => {
        const html = `
          <alchemy-tinymce toolbar="bold italic" foo-bar="bar | foo" min-height="400">
            <textarea id="${textareaId}"></textarea>
          </alchemy-tinymce>
        `
        component = renderComponent("alchemy-tinymce", html)
        expect(component.configuration.height).toEqual(400)
      })
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
