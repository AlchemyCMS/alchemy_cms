# TODO

== User:

* Move the cancan user abilities into alchemy-devise gem
* Refactor folded pages feature (not every user model is persisted)

* Fix element window reload after click on element window buttons (new element)
* Fix options json parsing, if null object. (Contents#new)
* Fix creation of non existing language tree (js redirect?)

## Caching-Redux

* Cache element views and touch all pages that have this element on if element gets publishes
  => (pages_sweeper#pages_to_be_sweeped)
* Cache esssence views with name and updated_at as cache_key
* Rack::Cache for pictures?
* Remove sweepers
* Benchmark disk usage of local file system cache
* Refactor Pages#flush. Use page.publish! ?
* Do we need the fallback to page_layouts/standard?
