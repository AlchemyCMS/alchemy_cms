## Alchemy Nodes

* Nodes are organized as nested set
  * has url (if node is a page, then copy page url to node url). if url is not present on node, try to call url (maybe to_param?) on related object.
* Everything can be a node in the tree:
  * engines (like spree)
  * external links
  * pages
  * even custom controllers
  * Record instances
  * Everything that responds_to(:to_param) (Maybe introduce a custom method? Like alchemy_node_url)
* Page is independent from navigation tree a can be a node of the tree
* Page is only a holder of cells and elements and has only some seo relevant data
  * public?
  * restricted?
* Page has many variants (language, other version, drafts, etc.)
  * PageVariant language:references draft:boolean version:integer
* Remove fold and such alike from page. Add to Node?
* Move Page#previous Page#next into Node?
* Move #copy_children_to, #first_public_child, #update_node!, #first_public_child.
  * All tree related methods from Page to Node
* Remove all nested set related columns from alchemy_pages table.
* Find a way to update pages urlname if the tree node was moved.
* Refactor systempages / layoutpages. We don't need them to be in a special tree anymore.
  * They can just be normal pages, that are not attached to a tree node.
