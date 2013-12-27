window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

Alchemy.showMenubar = ->
  menubar = document.getElementById('alchemy_menubar')
  if (typeof(menubar) != 'undefined' && menubar != null)
    menubar.style.display = "block"

Alchemy.showMenubar()
