import Hotkeys from "alchemy_admin/hotkeys"

function init(scope) {
  if (!scope) {
    Alchemy.watchForDialogs()
  }
  Hotkeys(scope)
  Alchemy.ListFilter(scope)
}

export default {
  init
}
