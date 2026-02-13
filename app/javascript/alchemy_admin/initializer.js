import Hotkeys from "alchemy_admin/hotkeys"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"

export default function Initializer() {
  // We obviously have javascript enabled.
  document.documentElement.classList.remove("no-js")

  // Initialize hotkeys.
  Hotkeys()

  // Add observer for please wait overlay.
  document.querySelectorAll(".please_wait").forEach((element) => {
    element.addEventListener("click", pleaseWaitOverlay)
  })

  // Hack for enabling tab focus for <a>'s styled as button.
  document.querySelectorAll("a.button").forEach((button) => {
    button.setAttribute("tabindex", 0)
  })

  // Override the filter of keymaster.js so we can blur the fields on esc key.
  key.filter = function (event) {
    let tagName = (event.target || event.srcElement).tagName
    return (
      key.isPressed("esc") ||
      !(tagName === "INPUT" || tagName === "SELECT" || tagName === "TEXTAREA")
    )
  }
}
