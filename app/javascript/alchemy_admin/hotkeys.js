import "keymaster"

Alchemy = window.Alchemy || {}
Alchemy.bindedHotkeys = []

export default function (scope) {
  // Unbind all previously registered hotkeys.
  if (!scope) {
    $(document).off("keypress")
    Alchemy.bindedHotkeys.forEach((hotkey) => key.unbind(hotkey))
  }

  // Binds keyboard shortcuts to search fields.
  const $search_fields = $(".search_input_field", scope)
  const $search_fields_clear = $(
    ".search_field_clear, .js_filter_field_clear",
    scope
  )

  key("alt+f", function () {
    key.setScope("search")
    $search_fields.focus()
    return false
  })
  Alchemy.bindedHotkeys.push("alt+f")

  key("esc", "search", function () {
    $search_fields_clear.click()
    $search_fields.blur()
  })
  Alchemy.bindedHotkeys.push("esc")

  if (!scope) {
    $(document).on("keypress", function (e) {
      if (
        !$(e.target).is("input, textarea") &&
        String.fromCharCode(e.which) === "?"
      ) {
        Alchemy.openDialog("/admin/help", {
          title: Alchemy.t("help"),
          size: "400x492"
        })
        return false
      } else {
        return true
      }
    })
  }

  // Binds click events to hotkeys.
  //
  // Simply add a data-alchemy-hotkey attribute to your link.
  // If a hotkey is triggered by user, the click event of the element gets triggerd.
  //
  $("[data-alchemy-hotkey]", scope).each(function () {
    const $this = $(this)
    const hotkey = $this.data("alchemy-hotkey")
    key(hotkey, () => $this.click())
    Alchemy.bindedHotkeys.push(hotkey)
  })
}
