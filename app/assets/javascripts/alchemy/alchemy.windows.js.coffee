$.extend Alchemy,

  # Opens an image in an overlay
  # Used by the picture library
  zoomImage: (url, title, width, height) ->
    $doc_width = $(window).width()
    $doc_height = $(window).height()
    if width > $doc_width
      width = $doc_width
    if height > $doc_height
      height = $doc_height
    Alchemy.openDialog url,
      size: "#{width}x#{height}"
      title: title
      modal: false
      image_loader_color: '#000'

  # Trash window methods
  TrashWindow:

    # Opens the trash window
    open: (page_id, title) ->
      url = Alchemy.routes.admin_trash_path(page_id)
      Alchemy.TrashWindow.current = new Alchemy.Dialog url,
        title: title,
        size: '380x490',
        modal: false
      Alchemy.TrashWindow.current.open()

    # Refreshes the trash window
    refresh: ->
      if Alchemy.TrashWindow.current
        Alchemy.TrashWindow.current.reload()
