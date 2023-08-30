export class AlchemyHTMLElement extends HTMLElement {
  static properties = {}

  static get observedAttributes() {
    return Object.keys(this.properties)
  }

  constructor() {
    super()
  }

  connectedCallback() {
    // parse the properties object and register property variables
    Object.keys(this.constructor.properties).forEach((propertyName) => {
      this.updateProperty(propertyName, this.getAttribute(propertyName))
    })
    // render the component
    this.updateComponent()
  }

  attributeChangedCallback(name, oldValue, newValue) {
    this.updateProperty(name, newValue)
    this.updateComponent()
  }

  /**
   * update the property value
   * if the value is undefined the default value is used
   *
   * @param {string} propertyName
   * @param {string} value
   */
  updateProperty(propertyName, value) {
    const property = this.constructor.properties[propertyName]
    this[propertyName] = value
    if (property.default && this[propertyName] === null) {
      this[propertyName] = property.default
    }
  }

  /**
   * (re)render the component content inside the component container
   */
  updateComponent() {
    this.innerHTML = this.render()
  }

  /**
   * empty method container to allow the child component to put the rendered string into this method
   * @returns {String}
   */
  render() {
    return ""
  }
}
