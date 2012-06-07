$('#<%= content_dom_id(@content_dup) %>').remove()
Alchemy.growl '<%= escape_javascript(@notice) %>'
Alchemy.reloadPreview()
Alchemy.pleaseWaitOverlay false