/**
 * create a HTML element
 * @param {string} text
 * @returns {HTMLElement}
 */
export function createHtmlElement(text) {
  const element = document.createElement("template")
  element.innerHTML = text
  return element.content.children[0]
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
