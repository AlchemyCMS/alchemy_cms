import Hotkeys from "alchemy_admin/hotkeys"
import ListFilter from "alchemy_admin/list_filter"

function init(scope) {
  if (!scope) {
    Alchemy.watchForDialogs()
  }
  Hotkeys(scope)
  ListFilter(scope)
}

export default {
  init
}
