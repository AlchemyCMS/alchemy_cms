$.extend Alchemy,

  # Opens an image in a dialog
  # Used by the picture library
  zoomImage: (url, title, width, height) ->
    Alchemy.currentDialog = new Alchemy.Dialog url,
      size: "#{width}x#{height}"
      title: title
      padding: false
      overflow: 'hidden'
      ready: (dialog) ->
        Alchemy.ImageLoader dialog,
          color: '#000'
    Alchemy.currentDialog.open()

  # Trash window methods
  TrashWindow:

    # Opens the trash window
    open: (page_id, title) ->
      url = Alchemy.routes.admin_trash_path(page_id)
      Alchemy.TrashWindow.current = new Alchemy.Dialog url,
        title: title,
        size: '380x460',
        modal: false
      Alchemy.TrashWindow.current.open()

    # Refreshes the trash window
    refresh: ->
      if Alchemy.TrashWindow.current
        Alchemy.TrashWindow.current.reload()
