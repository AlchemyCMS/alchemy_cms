import Tooltips from "alchemy_admin/tooltips"
import CharCounter from "alchemy_admin/char_counter"
import Autocomplete from "alchemy_admin/autocomplete"

function init(scope) {
  Alchemy.SelectBox(scope)
  Alchemy.Datepicker(scope && scope.selector)
  Tooltips(scope)
  Alchemy.Buttons.observe(scope)
  if (!scope) {
    Alchemy.watchForDialogs()
  }
  Alchemy.Hotkeys(scope)
  Alchemy.ListFilter(scope)
  Autocomplete(scope)
  $("[data-alchemy-char-counter]", scope).each(function () {
    CharCounter(this)
  })
}

function initElement($el) {
  Alchemy.ElementDirtyObserver($el)
  init($el && $el.selector)
  Alchemy.ImageLoader($el[0])
  Alchemy.fileEditors(
    $el.find(
      ".ingredient-editor.file, .ingredient-editor.audio, .ingredient-editor.video"
    ).selector
  )
  Alchemy.pictureEditors($el.find(".ingredient-editor.picture").selector)
}

export default {
  init,
  initElement
}
