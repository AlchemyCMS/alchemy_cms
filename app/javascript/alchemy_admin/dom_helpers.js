/**
 * create a HTML element
 * @param {string} text
 * @returns {HTMLElement}
 */
export function createHtmlElement(text) {
  const element = document.createElement("div")
  element.innerHTML = text
  return element.firstElementChild
}

/**
 * wrap element with wrappingElement
 * @param {HTMLElement} element
 * @param {HTMLElement} wrappingElement
 */
export function wrap(element, wrappingElement) {
  element.replaceWith(wrappingElement)
  wrappingElement.appendChild(element)
}
