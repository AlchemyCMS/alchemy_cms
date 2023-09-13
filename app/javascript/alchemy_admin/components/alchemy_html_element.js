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
    // parse the properties object and register property variables
    Object.keys(this.constructor.properties).forEach((propertyName) => {
      // if the options was given via the constructor, they should be prefer (e.g. new <WebComponentName>({title: "Foo"}))
      if (this.options[propertyName]) {
        this[propertyName] = this.options[propertyName]
      } else {
        this._updateProperty(propertyName, this.getAttribute(propertyName))
      }
    })

    // render the component
    this._updateComponent()
    this.connected()
  }

  /**
   * triggered by the browser, if one of the observed attributes is changing
   * @link https://developer.mozilla.org/en-US/docs/Web/API/Web_Components#reference
   */
  attributeChangedCallback(name, oldValue, newValue) {
    this._updateProperty(name, newValue)
    this._updateComponent()
  }

  /**
   * a connected method to make it easier to overwrite the connection callback
   */
  connected() {}

  /**
   * empty method container to allow the child component to put the rendered string into this method
   * @returns {String}
   */
  render() {
    return this.initialContent
  }

  /**
   * (re)render the component content inside the component container
   * @private
   */
  _updateComponent() {
    if (this.changeComponent) {
      this.innerHTML = this.render()
      this.changeComponent = false
    }
  }

  /**
   * update the property value
   * if the value is undefined the default value is used
   *
   * @param {string} propertyName
   * @param {string} value
   * @private
   */
  _updateProperty(propertyName, value) {
    const property = this.constructor.properties[propertyName]
    if (this[propertyName] !== value) {
      this[propertyName] = value
      if (
        typeof property.default !== "undefined" &&
        this[propertyName] === null
      ) {
        this[propertyName] = property.default
      }
      this.changeComponent = true
    }
  }
}
