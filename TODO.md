# TODO

== User:

* Move the cancan user abilities into alchemy-devise gem
* Refactor folded pages feature (not every user model is persisted)

* Fix element window reload after click on element window buttons (new element)
* Fix options json parsing, if null object. (Contents#new)
* Validate for uniqueness of element and content names (scoped to element)

## Caching-Redux

* Write template_tracker specs!
* Cache element views and touch all pages that have this element on if element gets published
  => (pages_sweeper#pages_to_be_sweeped)
* Cache esssence views with name and updated_at as cache_key
* Rack::Cache for pictures?
* Remove sweepers
* Benchmark disk usage of local file system cache
* Refactor Pages#flush. Use page.publish! ?
* Do we need the fallback to page_layouts/standard?
* Don't cache in to preview window!
  * Maybe we need a element view helper that handles caching in the preview mode
  * And the preview mode code (data-alchemy-element attr)

## New rails-like rendering method

* What with editor views?
  * use render i.e. element.editor?

* Remove render_elements
  * What options are needed?
  * Make useful instance methods and scopes
  * What with elements in cell?

* Remove render_cell
  * What options are needed?
  * Make useful instance methods and scopes
  * What with elements in cell?

* Remove render_page_layout
  * What options are needed?
  * Make useful instance methods and scopes

* Remove render_essence
  * What options are needed?
  * Make useful instance methods and scopes
