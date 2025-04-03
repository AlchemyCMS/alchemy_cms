import { setupTranslations } from "../translations.helper"

/**
 * render component helper
 * @param {string} name
 * @param {string} html
 * @returns {HTMLElement}
 */
export const renderComponent = (name, html) => {
  document.body.innerHTML = html
  return document.querySelector(`${name}, [is="${name}"]`)
}

export const setupLanguage = () => {
  document.documentElement.lang = "en"
  setupTranslations()
}
