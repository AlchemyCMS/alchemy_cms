Pages
-----

Pages are organized in language based tree structures and represent your
the navigation of your website.

Pages **do not hold the actual content**. The actual content is stored
in the [essences](essences.html) inside the elements of the pages.

Beside a language, a Page has attributes for its names, visibility,
published and restriction status and all SEO relevant attributes like
meta tags and meta descriptions.

Every Page has a [page\_layout](page_layouts.html) which defines
additional properties like caching, uniqueness, feed, … and it also
defines [elements](elements.html) and [cells](cells.html) that can be
placed on that Page.\
endprologue.

### Global pages

Global pages (or layout pages) are pages that are not in the default
page tree (your navigation). They will never get rendered completely.
Use them to store shared elements that should be rendered on multiple
other pages (ie. sidebars, footer, header, etc) or somewhere directly on
the application layout.

To define a global page set <code>layoutpage: true</code> in the page
layout definition of that page.

#### Render an element from a global page

To render an element from a global page use the from\_page option of the
<code>render\_elements</code> helper.

Example:

<erb>\
\<= render\_elements only: ’news\_teaser’, from\_page: ’sidebar’\>\
</erb>

NOTE: You can pass a page\_layout name as a String, an array of
page\_layout names, or an instance of a certain Page.

### Render a page content

INFO: coming soon.

 
