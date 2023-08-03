import TagsAutocomplete from "alchemy_admin/tags_autocomplete"
import Tooltips from "alchemy_admin/tooltips"

/**
 * translate the jQuery scope into a native Element
 * @param scope
 * @returns {Element|Document}
 */
function currentElement(scope) {
  if (scope && scope.length > 0) {
    return scope[0]
  } else {
    return document
  }
}

function init(scope) {
  const element = currentElement(scope)

  Alchemy.SelectBox(scope)
  Alchemy.Tooltips(element)
  Alchemy.Buttons.observe(scope)
  if (!scope) {
    Alchemy.watchForDialogs()
  }
  Alchemy.Hotkeys(scope)
  Alchemy.ListFilter(scope)
  TagsAutocomplete(scope)
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
