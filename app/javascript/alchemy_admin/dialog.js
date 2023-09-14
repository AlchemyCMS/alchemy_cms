import { Dialog } from "alchemy_admin/components/dialog"

export function closeCurrentDialog(callback) {
  document.querySelector("alchemy-dialog").close()
  if (typeof callback === "function") {
    callback()
  }
}
/**
 * @param {string} url
 * @param {options} options
 */
export function openDialog(url, options = {}) {
  const dialog = new Dialog({ url, ...options })
  document.body.append(dialog)
  dialog.open()
}
