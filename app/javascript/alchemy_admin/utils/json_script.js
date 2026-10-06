/**
 * Reads the data the server rendered into a JSON script tag
 * @param {string} id
 * @returns {any|undefined} undefined if no such script tag is present
 */
export function readJSONScript(id) {
  const script = document.getElementById(id)

  if (!script) return undefined

  return JSON.parse(script.textContent)
}
