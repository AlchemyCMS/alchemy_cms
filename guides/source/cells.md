Cells
-----

Cells are sections on a page and are acting as containers for elements.

endprologue.

### Defining cells

Cells are defined here:

<code>config/alchemy/cells.yml</code>

You also have to define the cells to use in your
<code>config/alchemy/page\_layouts.yml</code>

Please be aware: You can only add elements that are both defined in your
cells.yml and page\_layouts.yml!

#### Example

cells.yml

<yaml>\
- name: left\_column\
 elements: [image, text]\
</yaml>

page\_layouts.yml

<yaml>\
- name: standard\
 cells: left\_column\
 elements: [image, text]\
</yaml>

Normally cells are rendered on page\_layouts. They can be called with
this helper method:

<erb>\
\<= render\_cell(:cellname)\>\
</erb>

If you render cells like this, an additional view-partial is rendered,
naming scheme is
<code>/app/views/alchemy/cells/\_left\_column.html.erb</code>

In this partial use <code>\<= render\_elements :from\_cell =\>
’left\_column’\></code> to render cell-related elements only.
