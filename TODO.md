# Inplace Edit TODO

* Fix element editor live update, while changing text in preview
* Fix: If element is dirty, getting blurred and focused again, then the save button is disables. Should be enabled (This is because the whole element is set clean, after saving the content. see below)
* Implement link dialog feature (Load all dependent styles and scripts)
* Dirty/Clean should only trigger on content editor, not on whole element
* Set the content to clean (in preview window), after save, not after blur.

## Frontend CSS
  * Prefix all classes with `alchemy`, so we don't override page frontend
  * Modularize CSS so we only load must-haves in the frontend

## Thoughts

* Maybe we can call Dialogs and other internal Alchemy stuff (linking pages) from preview window's parent?
