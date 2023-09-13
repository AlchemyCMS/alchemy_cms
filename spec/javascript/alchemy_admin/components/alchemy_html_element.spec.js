import { AlchemyHTMLElement } from "../../../../app/javascript/alchemy_admin/components/alchemy_html_element"
import { renderComponent } from "./component.helper"

describe("AlchemyHTMLElement", () => {
  let component = undefined

  const componentName = () =>
    `test-element-${Math.ceil(Math.random() * 10000000000000)}`

  describe("Render", () => {
    /**
     * create a new web component
     * you can't recreate (or remove) a web component. So it has to be a new one with another name
     * @param {string} content
     * @param {string} initialContent
     */
    const createComponent = (content = "", initialContent = "") => {
      const name = componentName()

      customElements.define(
        name,
        class Test extends AlchemyHTMLElement {
          render() {
            return content
          }
        }
      )
      component = renderComponent(name, `<${name}>${initialContent}</${name}>`)
    }

    it("should render only the component", () => {
      createComponent()
      expect(component).toBeInstanceOf(HTMLElement)
      expect(component.innerHTML).toEqual("")
    })

    it("should render the content of the given render function", () => {
      createComponent("Foo")
      expect(component.innerHTML).toEqual("Foo")
    })

    it("should store the initial content", () => {
      createComponent("", "Bar")
      expect(component.initialContent).toEqual("Bar")
    })

    it("should render the initial content if no render function is given", () => {
      customElements.define(
        "test-initial-content",
        class Test extends AlchemyHTMLElement {}
      )
      component = renderComponent(
        "test-initial-content",
        `<test-initial-content>FooBar</test-initial-content>`
      )
      expect(component.innerHTML).toEqual("FooBar")
    })
  })

  describe("Attributes", () => {
    /**
     * @param {string} name
     */
    const createComponent = (name = componentName()) => {
      customElements.define(
        name,
        class Test extends AlchemyHTMLElement {
          static properties = {
            size: { default: "medium" },
            color: { default: "currentColor" }
          }
        }
      )
      component = renderComponent(name, `<${name}></${name}>`)
    }

    it("should configure attributes and set default values", () => {
      createComponent()
      expect(component.size).toEqual("medium")
      expect(component.color).toEqual("currentColor")
    })

    it("should be able to set attributes", () => {
      createComponent("test-size")
      component = renderComponent(
        "test-size",
        `<test-size size="large"></test-size>`
      )
      expect(component.size).toEqual("large")
    })

    it("should observe an attribute change", () => {
      createComponent("test-color")
      expect(component.color).toEqual("currentColor")
      component.setAttribute("color", "pink")
      expect(component.color).toEqual("pink")
    })

    it("should rerender after a attribute change", () => {
      customElements.define(
        "test-attribute-change",
        class Test extends AlchemyHTMLElement {
          static properties = {
            foo: { default: "bar" }
          }

          render() {
            return `Test: ${this.foo}`
          }
        }
      )
      component = renderComponent(
        "test-attribute-change",
        "<test-attribute-change foo='foo'></test-attribute-change>"
      )
      expect(component.innerHTML).toEqual("Test: foo")
      component.setAttribute("foo", "fooBar")
      expect(component.innerHTML).toEqual("Test: fooBar")
    })
  })

  describe("Options", () => {
    class Test extends AlchemyHTMLElement {
      static properties = {
        test: { default: "foo" }
      }
    }

    beforeAll(() => {
      customElements.define("test-options", Test)
      component = renderComponent(
        "test-options",
        "<test-options></test-options>"
      )
    })

    it("should have options", () => {
      const newComponent = new Test({ test: "bar" })
      expect(newComponent.options).toEqual({ test: "bar" })
    })

    it("should use the given option as default property", () => {
      const newComponent = new Test({ test: "bar" })
      document.body.append(newComponent) // the new component should be append to a DOM node to run as a Web Component
      expect(component.test).toEqual("foo")
      expect(newComponent.test).toEqual("bar")
    })
  })
})
