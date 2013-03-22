# Alchemy 2.6.0 TODO

* Set autofocus on useful elements in dialogs (jQueryUI 1.10 autofocus "feature")
* icon-font replacement
  * overlay resize handle
* Update selectboxit
* Refactor url nesting feature
  * Fix: page gets created, although its not valid. Maybe transaction with rollback?
  * rake task for converting urlnames should create legacy urls.
  * Maybe set url nesting to default?
  * Store a legacy pagename with every urlname change
* Do not show not visible pages in breadcrumb helper
