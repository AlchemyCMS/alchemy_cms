# TODO

== User:

* Move the cancan user abilities into alchemy-devise gem
* Refactor folded pages feature (not every user model is persisted)

* Fix element window reload after click on element window buttons (new element)
* Validate for uniqueness of element and content names (scoped to element)

## Caching-Redux

* spec all essence views
* Cache element views and touch all pages that have this element on if element gets published
  => (pages_sweeper#pages_to_be_sweeped)
* Rack::Cache for pictures?
* Remove sweepers
* Benchmark disk usage of local file system cache
* Refactor Pages#flush. Use page.publish! ?
* Don't cache in to preview window!
  * Maybe we need a element view helper that handles caching in the preview mode
  * And the preview mode code (data-alchemy-element attr)
