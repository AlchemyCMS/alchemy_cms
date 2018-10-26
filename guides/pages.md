# Pages

Pages are organized in language based tree structures and represent your the navigation of your website.

Pages **do not hold the actual content**. The actual content is stored in the [essences](essences.html) inside the elements of the pages.

Beside a language, a Page has attributes for its names, visibility, published and restriction status and all SEO relevant attributes like meta tags and meta descriptions.

Every Page has a [page_layout](page_layouts.html) which defines additional properties like caching, uniqueness, feed, ... and it also defines [element](elements.html) and [cells](cells.html) that can be placed on that Page.

## Global pages

Global pages (or layout pages) are pages that are not in the default page tree (your navigation). They will never get rendered completely. Use them to store shared elements that should be rendered on multiple other pages (ie. sidebars, footer, header, etc) or somewhere directly on the application layout.

To define a global page set `layoutpage: true` in the page layout definition of that page.

### Render an element from a global page

To render an element from a global page use the from_page option of the `render_elements` helper.

#### Example

~~~ erb
<%= render_elements only: 'news_teaser', from_page: 'sidebar' %>
~~~

::: tip
You can pass a `page_layout` name as a String, an array of page layout names, or an instance of a certain `Alchemy::Page`.
:::
