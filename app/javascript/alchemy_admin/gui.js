import { watchForDialogs } from "alchemy_admin/dialog"
import Hotkeys from "alchemy_admin/hotkeys"

export function init(scope) {
  if (!scope) {
    watchForDialogs()
  }
  Hotkeys(scope)
}

export default {
  init
}
