window.Alchemy = {} if typeof(window.Alchemy) is 'undefined'

# Responsible for the live preview feature
window.Alchemy.LivePreview =

  # Store the currently binded rtf editor instance
  currentBindedRTFEditors: []

  # Binds live editing events for given element
  bind: ($element) ->
    self = Alchemy.LivePreview
    # unbind keyup events of all other elements
    $('.essence_text.content_editor input[type="text"]').off 'keyup'
    # rebind for current element
    $('.essence_text.content_editor input[type="text"]', $element).on 'keyup', self.textUpdateEvent
    $element.bind 'Alchemy.PictureChange', self.imageUpdateEvent
    self.bindUpdateOnRTFs($element)

  # Binds live editing events for all tinymce editors in given element
  bindUpdateOnRTFs: ($element) ->
    self = Alchemy.LivePreview
    $('.essence_richtext.content_editor textarea', $element).each ->
      rtf_id = $(this).attr('id')
      if rtf_id and rtf_id not in self.currentBindedRTFEditors
        self.currentBindedRTFEditors.push rtf_id
        ed = tinymce.get(rtf_id)
        ed.on 'keyup', (e) -> self.rtfUpdateEvent(e, ed)
        ed.on 'change', (e) -> self.rtfUpdateEvent(e, ed)

  # Updates the content of the currently edited text element in the preview window
  textUpdateEvent: (e) ->
    $this = $(this)
    content = Alchemy.getCurrentPreviewElement $this.data('alchemy-content-id')
    content.text $this.val()
    true

  # Updates the content of the currently edited richtext element in the preview window
  rtfUpdateEvent: (e, ed) ->
    textarea = $("##{ed.id}")
    content = Alchemy.getCurrentPreviewElement textarea.data('alchemy-content-id')
    content.html ed.getContent()
    true

  # Updates the content of the currently edited picture element in the preview window
  imageUpdateEvent: (e, content_id, url) ->
    content = Alchemy.getCurrentPreviewElement content_id
    img = new Image
    img.src = url
    content.html(img)
    true
