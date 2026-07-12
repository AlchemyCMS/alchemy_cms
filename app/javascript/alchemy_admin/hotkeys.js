import "keymaster"

const bindedHotkeys = []

export default function (scope = document) {
  // Unbind all previously registered hotkeys if we are not inside a dialog.
  if (scope === document) {
    bindedHotkeys.forEach((hotkey) => key.unbind(hotkey))
  }

  // Binds keyboard shortcuts to search fields.
  const search_fields = scope.querySelectorAll(".search_input_field")
  const search_fields_clear = scope.querySelectorAll(
    ".search_field_clear, .js_filter_field_clear"
  )
  key("alt+f", function () {
    key.setScope("search")
    search_fields.forEach((el) => el.focus({ focusVisible: true }))
    return false
  })
  bindedHotkeys.push("alt+f")
  key("esc", "search", function () {
    search_fields_clear.forEach((el) => el.click())
    search_fields.forEach((el) => el.blur())
  })
  bindedHotkeys.push("esc")

  // Binds click events to buttons with hotkeys.
  //
  // Simply add a data-alchemy-hotkey attribute to your link.
  // If a hotkey is triggered by user, the click event of the element gets triggerd.
  //
  scope.querySelectorAll("[data-alchemy-hotkey]").forEach(function (el) {
    const hotkey = el.dataset.alchemyHotkey
    key(hotkey, () => el.click())
    bindedHotkeys.push(hotkey)
  })
}
