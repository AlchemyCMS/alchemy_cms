$('#<%= @content_dom_id %>').remove()
Alchemy.growl '<%= j @notice %>'
Alchemy.reloadPreview()
Alchemy.pleaseWaitOverlay false
