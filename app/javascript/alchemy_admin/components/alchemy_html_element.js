import { toCamelCase } from "alchemy_admin/utils/string_conversions"

export class AlchemyHTMLElement extends HTMLElement {
  static properties = {}

  /**
   * create the list of observed attributes
   * this function is a requirement for the `attributeChangedCallback` - method
   * @returns {string[]}
   * @link https://developer.mozilla.org/en-US/docs/Web/API/Web_Components#reference
   */
  static get observedAttributes() {
    return Object.keys(this.properties)
  }

  constructor(options = {}) {
    super()

    this.options = options
    this.changeComponent = true
    this.initialContent = this.innerHTML // store the inner content of the component
  }

  /**
   * run when the component will be initialized by the Browser
   * this is a default function
   * @link https://developer.mozilla.org/en-US/docs/Web/API/Web_Components#reference
   */
  connectedCallback() {
    // parse the properties object and register property with the default values
    Object.keys(this.constructor.properties).forEach((name) => {
      // if the options was given via the constructor, they should be prefer (e.g. new <WebComponentName>({title: "Foo"}))
      this[name] =
        this.options[name] ?? this.constructor.properties[name].default
    })

    // then process the attributes
    this.getAttributeNames().forEach((name) => this._updateFromAttribute(name))

    // render the component
    this._updateComponent()
    this.connected()
  }

  /**
   * disconnected callback if the component is removed from the DOM
   * this is currently only a Proxy to the disconnected - callback to use the same callback structure
   * as for the connected - callback
   * @link https://developer.mozilla.org/en-US/docs/Web/API/Web_Components#reference
   */
  disconnectedCallback() {
    this.disconnected()
  }

  /**
   * triggered by the browser, if one of the observed attributes is changing
   * @link https://developer.mozilla.org/en-US/docs/Web/API/Web_Components#reference
   */
  attributeChangedCallback(name) {
    this._updateFromAttribute(name)
    this._updateComponent()
  }

  /**
   * a connected method to make it easier to overwrite the connection callback
   */
  connected() {}

  /**
   * a disconnected method to make it easier to overwrite the disconnection callback
   */
  disconnected() {}

  /**
   * empty method container to allow the child component to put the rendered string into this method
   * @returns {String}
   */
  render() {
    return this.initialContent
  }

  /**
   * after render callback
   * the function will be triggered after the DOM was updated
   */
  afterRender() {}

  /**
   * (re)render the component content inside the component container
   * @private
   */
  _updateComponent() {
    if (this.changeComponent) {
      this.innerHTML = this.render()
      this.changeComponent = false
      this.afterRender()
    }
  }

  /**
   * update the value from the given attribute
   *
   * @param {string} name
   * @private
   */
  _updateFromAttribute(name) {
    const attributeValue = this.getAttribute(name)
    const propertyName = toCamelCase(name)
    const isBooleanValue =
      attributeValue.length === 0 || attributeValue === "true"

    const value = isBooleanValue ? true : attributeValue

    if (this[propertyName] !== value) {
      this[propertyName] = value
      this.changeComponent = true
    }
  }
}
