function init(scope) {
  if (!scope) {
    Alchemy.watchForDialogs()
  }
  Alchemy.Hotkeys(scope)
  Alchemy.ListFilter(scope)
}

export default {
  init
}
