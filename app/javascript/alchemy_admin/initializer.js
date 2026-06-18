import Hotkeys from "alchemy_admin/hotkeys"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"
import { openDialog } from "alchemy_admin/dialog"

// Opens the help dialog when the user presses the "?" key outside of a field.
function showHelp(evt) {
  if (
    !$(evt.target).is("input, textarea") &&
    String.fromCharCode(evt.which) === "?"
  ) {
    openDialog("/admin/help", {
      title: Alchemy.t("help"),
      size: "400x492"
    })
    return false
  } else {
    return true
  }
}

export default function Initializer() {
  // We obviously have javascript enabled.
  document.documentElement.classList.remove("no-js")

  // Initialize hotkeys.
  Hotkeys()

  // (Re)bind the help dialog hotkey.
  document.removeEventListener("keypress", showHelp)
  document.addEventListener("keypress", showHelp)

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
