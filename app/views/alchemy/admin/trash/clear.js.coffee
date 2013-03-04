Alchemy.growl '<%= _t("Cleared trash") %>'
Alchemy.TrashWindow.refresh <%= @page.id %>
jQuery('#element_trash_button .icon').removeClass 'full'
Alchemy.pleaseWaitOverlay false