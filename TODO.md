# Alchemy 2.6.0 TODO

* Set autofocus on useful elements in dialogs (jQueryUI 1.10 autofocus "feature")
* icon-font replacement
  * overlay resize handle
* Update selectboxit
* Do not show not visible pages in breadcrumb helper
* Fix resource relations with alchemy models (ie: alchemy/user)
* horizontal scrollable resources table
* Fix resources search for columns that use releations
  * maybe refactor relation hash => attribute = {:name => 'name', :type => :string, :table => :companies}
  * better use join to join the releated table and seach the attribute on that