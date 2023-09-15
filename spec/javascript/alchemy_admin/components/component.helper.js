/**
 * render component helper
 * @param {string} name
 * @param {string} html
 * @returns {HTMLElement}
 */
export const renderComponent = (name, html) => {
  document.body.innerHTML = html
  return document.querySelector(name)
}
