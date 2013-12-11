$('#<%= @content_dom_id %>').remove()
Alchemy.growl '<%= escape_javascript(@notice) %>'
Alchemy.reloadPreview()
Alchemy.pleaseWaitOverlay false
