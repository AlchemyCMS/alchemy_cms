---
prev: /pages.html
next: /elements.html
---

# Cells

::: warning Deprecation note
With Alchemy 4.2 cells have now been superseded by [fixed elements](/elements.html#render-a-group-of-elements-on-a-fixed-place-on-the-page).
:::

Cells are fixed areas on a page and act as element containers.

Often you have fixed sections on a page like a sidebar or the popular hero. These are perfect candidates for cells.

If you want to be able to change the position of element containers, you probably want to use [nestable elements](/elements.html#nestable-elements) instead.

## Defining cells

Cells are defined here:

~~~
config/alchemy/cells.yml
~~~

You also have to define the cells to use in your `config/alchemy/page_layouts.yml`

::: warning INFO
You can only add elements that are both defined in your `cells.yml` and `page_layouts.yml`!
:::

### Examples

~~~ yaml
# cells.yml
- name: left_column
  elements: [image, text]
~~~

~~~ yaml
# page_layouts.yml
- name: standard
  cells: [left_column]
  elements: [image, text]
~~~

## Render cells

Normally cells are rendered on page_layouts. They can be called with this helper method:

~~~ erb
<%= render_cell(:cellname) %>
~~~

If you render cells like this, an additional view-partial is rendered, naming scheme is `/app/views/alchemy/cells/_left_column.html.erb`

### Render elements from cell

In this partial use `<%= render_elements from_cell: 'left_column' %>` to render cell-related elements only.
