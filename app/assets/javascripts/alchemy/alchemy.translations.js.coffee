window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

$.extend Alchemy,

  # Holds translations
  #
  translations:
    page_dirty_notice:
      en: "You have unsaved changes on this page. They will be lost if you continue."
      de: "Sie haben ungesicherte Änderungen auf der Seite. Diese gehen verloren, wenn Sie fortfahren."
    element_dirty_notice:
      en: "This element has unsaved changes. Do you really want to fold it?"
      de: "Dieses Element hat nicht gespeicherte Änderungen. Möchten Sie es wirklich einklappen?"
    warning:
      en: 'Warning!'
      de: 'Achtung!'
    ok:
      en: 'Ok'
      de: 'Ok'
    cancel:
      en: 'Cancel'
      de: 'Abbrechen'
