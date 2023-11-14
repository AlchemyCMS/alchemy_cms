import TagsAutocomplete from "alchemy_admin/tags_autocomplete"

function init(scope) {
  if (!scope) {
    Alchemy.watchForDialogs()
  }
  Alchemy.Hotkeys(scope)
  Alchemy.ListFilter(scope)
  TagsAutocomplete(scope)
}

export default {
  init
}
