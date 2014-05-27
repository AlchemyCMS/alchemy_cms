# Inplace Edit TODO

* Fix element editor live update, while changing text in preview
* Fix: If element is dirty, getting blurred and focused again, then the save button is disables. Should be enabled (This is because the whole element is set clean, after saving the content. see below)
* Implement/Fix link dialog feature (Cannot read property 'link_admin_pages_path' of undefined)
* Dirty/Clean should only trigger on content editor, not on whole element
* Set the content to clean (in preview window), after save, not after blur.
