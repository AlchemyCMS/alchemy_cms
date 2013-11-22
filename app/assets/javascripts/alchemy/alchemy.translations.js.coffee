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
    browse:
      de: "durchsuchen"
      en: "browse"
    pending:
      de: "Wartend..."
      en: "Pending..."
    uploading:
      de: "Ladend..."
      en: "Uploading..."
    remaining:
      de: " verbleibend."
      en: " remaining."
    complete:
      de: "Abgeschlossen"
      en: "Complete"
    cancelled:
      de: "Abgebrochen"
      en: "Cancelled"
    stopped:
      de: "Gestoppt"
      en: "Stopped"
    upload_failed:
      de: "Fehlgeschlagen!"
      en: "Upload Failed!"
    file_too_big:
      de: "Datei ist zu groß!"
      en: "File is too big!"
    upload_limit_exceeded:
      de: "Maximales Dateilimit erreicht."
      en: "Upload limit exceeded."
    validation_failed:
      de: "Validierung fehlgeschlagen. Ladevorgang angehalten."
      en: "Failed Validation. Upload skipped."
    zero_byte_file:
      de: "Datei hat keinen Inhalt!"
      en: "Cannot upload Zero Byte files!"
    invalid_file:
      de: "Ungültiger Dateityp!"
      en: "Invalid File Type!"
    unknown_error:
      de: "Unbekannter Fehler!"
      en: "Unhandled Error!"
    drag_files_notice:
      de: "Oder ziehen Sie die Dateien hier rauf"
      en: "Or drag files over here"
    drop_files_notice:
      de: "Lassen Sie die Dateien nun los"
      en: "Now drop the files"
    queued_files_notice:
      de: "x Dateien in der Warteschlange."
      en: "Queued x files."
    success_notice:
      de: "x Dateien hochgeladen."
      en: "Uploaded x files."
