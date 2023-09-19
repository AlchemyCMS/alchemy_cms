/**
 * convert dashes and underscore strings into camelCase strings
 * @param {string} str
 * @returns {string}
 */
export function toCamelCase(str) {
  return str
    .split(/-|_/)
    .reduce((a, b) => a + b.charAt(0).toUpperCase() + b.slice(1))
}
