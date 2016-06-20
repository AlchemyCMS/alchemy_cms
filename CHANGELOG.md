# Change Log

## 3.3.1 (unreleased)

* Fix use of Alchemy::Resource with namespaced models (#729)
* Allow setting the type of EssenceText input fields in the elements.yml via `settings[:input_type]`
* Admin locale switching does not switch language tree any more (#1065)
* Fixes bug where old site session causes not found errors (#1047)

## 3.3.0 (2016-05-18)

__New Features__

* Add support for Sprockets 3
* Add support for jquery-rails 4.1
* Show a welcome page, if no users or pages are present yet
* Namespace spec files
* Image library slideshow
* Global "current locked pages" tabs
* New option `linkable: false` for `EssencePicture`
* Allow custom routing for admin backend
* Resource forms can now have Tinymce enabled by adding `.tinymce` class
* `Alchemy::EssenceFile` now has a `link_text` attribute, so the editor is able to change the linked text of the download link.
* Enable to pass multiple page layout names to `on_page_layout` callbacks
* Client side rendering of the pages admin
* Deprecate `redirect_index` configuration
* Add Nestable elements feature
* Default site in seeder is now configurable
* Frontpage name and page layout are now editable when creating new language trees

__Notable Changes__

* Essence generator does not namespace the model into `Alchemy` namespace anymore
* New simplified uploader that allows to drag and drop images onto the archive everywhere in your app
  - Model names in uploader `allowed_filetypes` setting are now namespaced.
    Please be sure to run `rake alchemy:upgrade` to update your settings.
* Allow uppercase country codes
* Uses Time.current instead of Time.now for proper timezone support
* Adds year to `created_at` column of attachments table
* Removes "available contents" feature.
* Use Ransack for Admin Resources filtering, sorting and searching
* Renames Alchemy translation helpers from `_t` to `Alchemy.t`
* Do not append geometry string to preprocess option
* Skip the default locale in urls
* Add a proper index route and do not redirect to page anymore
* Updates Tinymce to 4.2.3
* Moves page status info into reusable partial
* Refactors factories into individual requirable files
* Do not raise error if `element_ids` params is missing while ordering elements
* Removes old middleware for rescueing legacy sessions
* Use rails tag helpers instead of plain HTML for meta tags
* Remove the duplication of `#decription` vs. `#definition`
* Resource CSV export now includes ID column and does not truncate large text columns anymore
* `Alchemy::Attachment#urlname` now returns always an escaped urlname w/o format suffix and does not convert the `file_name` once on create anymore
* Speed up the admin interface significantly when handling a large amount of pages

__Fixed Bugs__

* Add `locale` to `Alchemy::Language` to avoid errors for languages with missing locale files #831
* Fixes `Alchemy::PageLayout.get_all_by_attributes`
* Fix tag list display in picture library
* Animated GIFs display correctly
* EssenceSelect grouped options tags
* Add missing element partials for dummy app
* Eliminate an SQL lookup on frontend cached element partials
* Add missing german and spanish translation for element toolbar
* Use the site_id parameter and the session only in the Admin area
* Render 404 if accessing an unpublished index page that has "on page layout" callbacks

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.2.1...v3.3.0)

## 3.2.1 (2016-03-31)

__Fixed Bugs__

* Fix constant lookup issues with registered abilites
* Fix: `EssenceSelect` grouped `select_values`
* Respect `:reverse` option when sorting elements
* Directly updates position in database while sorting contents
* Don't show trashed elements when using a fallback
* Fixes wrong week number in datepicker

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.2.0...v3.2.1)

## 3.2.0 (2015-07-31)

[Release Notes](https://github.com/AlchemyCMS/alchemy_cms/releases/tag/v3.2.0)

## 3.1.3 (2016-01-21)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.1.1...v3.1.3)

## 3.1.2 (yanked)

No changes

## 3.1.1 (2015-03-17)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.1.0...v3.1.1)

## 3.1.0 (2015-02-24)

[Release Notes](https://github.com/AlchemyCMS/alchemy_cms/releases/tag/v3.1.0)

## 3.0.4 (2015-03-17)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.0.3...v3.0.4)

## 3.0.3 (2014-12-24)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.0.2...v3.0.3)

## 3.0.2 (2014-09-30)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.0.1...v3.0.2)

## 3.0.1 (2014-09-11)

[Full Change Log](https://github.com/AlchemyCMS/alchemy_cms/compare/v3.0.0...v3.0.1)

## 3.0.0 (2014-07-03)

[Release Notes](https://github.com/AlchemyCMS/alchemy_cms/releases/tag/v3.0.0)
