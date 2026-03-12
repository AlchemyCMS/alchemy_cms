---
prev:
  text: Ingredients
  link: ingredients
next:
  text: Menus
  link: menus
---

# Pages

Pages in Alchemy do not hold content directly. Content is stored in [ingredients](ingredients) inside [elements](elements) that are placed on pages. A page defines which elements are available, how caching behaves, and where the page appears in the site's URL structure.

Pages are organized as a nested tree and have a unique URL slug. Each page has attributes for name, title, visibility, published status, and SEO metadata like meta description and meta keywords.

Every page has a [page layout](#defining-page-layouts) — a definition that controls which elements can be placed on it and how the page behaves.

## Defining Page Layouts

Page layouts are defined in the `config/alchemy/page_layouts.yml` file. Each page layout needs at least a name.

### Example

A contact page with a headline, a contact form, and a text element. The page should be unique (only one per language), and must not be cached because of form validation messages.

~~~ yaml
# config/alchemy/page_layouts.yml
- name: contact
  cache: false
  unique: true
  elements: [headline, contactform, text]
  autogenerate: [headline, contactform]
~~~

## Page Layout Settings

### name
`String` _required_

A lowercased unique name for the page layout. Separate words with underscores. This name is used to match the view partial in `app/views/alchemy/page_layouts/` and is [translatable](#translating-page-layout-names) for the admin interface.

### elements
`Array`

A list of [element](elements) names that can be placed on pages of this type. Elements are defined in `config/alchemy/elements.yml`.

~~~ yaml
- name: homepage
  elements: [hero, article, gallery]
~~~

### autogenerate
`Array`

A list of element names that are created automatically when a new page of this type is created.

### unique
`Boolean` (Default: `false`)

When `true`, this page layout can only be used once per language tree.

### cache
`Boolean` (Default: `true`)

Set to `false` to disable cache headers for pages of this type. Recommended for pages with forms.

### layoutpage
`Boolean` (Default: `false`)

Marks this as a [global page](#global-pages) — a page outside the normal page tree used for shared elements like headers and footers.

### hide
`Boolean` (Default: `false`)

When `true`, this page layout is hidden from the "create new page" dialog.

### searchresults
`Boolean` (Default: `false`)

When `true`, this page layout is used to render fulltext search results.

### searchable
`Boolean` (Default: `true`)

When `false`, pages of this type are excluded from the built-in fulltext search.

### editable_by
`String|Array`

Restrict which [user roles](configuration#user-roles) can edit pages of this type.

### fixed_attributes
`Hash`

Lock specific page attributes to fixed values that editors cannot change. The fixed values are enforced at save time and override any editor changes.

~~~ yaml
- name: readonly_page
  fixed_attributes:
    public_on: ~
    public_until: ~
    restricted: false
~~~

### insert_elements_at
`String`

Set to `top` to insert new elements at the top of the page instead of the bottom (default).

### hint
`String|Boolean`

A tooltip displayed to content editors when selecting this page layout. Set to `true` to use the I18n key `alchemy.page_layout_hints.<name>`.

## Page Templates

Each page layout has a view partial that is rendered inside the application layout (`app/views/layouts/application.html.erb`).

Page layout partials live in `app/views/alchemy/page_layouts/` and are named after the page layout.

::: warning NOTE
If no partial is found for a page layout, the `_standard.html.erb` partial is rendered instead.
:::

### Template Generator

Alchemy provides a generator that creates page layout partials for all defined layouts.

~~~ bash
bin/rails g alchemy:page_layouts --skip
~~~

::: tip
Pass `--template-engine` or `-e` to use `haml`, `slim`, or `erb`. The default follows your Rails application's template engine setting.
:::

### Rendering Elements

The generated partial contains a single call to render all elements on the page.

~~~ erb
<%= render_elements %>
~~~

Customize the HTML around this call to match your design. The `render_elements` helper accepts several options:

~~~ erb
<%# Render only specific elements %>
<%= render_elements only: "article" %>

<%# Render all except certain elements %>
<%= render_elements except: ["header", "footer"] %>
~~~

## Global Pages

Global pages (or layout pages) live outside the normal page tree. They are never rendered on their own. Use them to store shared elements that appear on multiple pages — for example, a footer, header, or tracking codes.

To define a global page, set `layoutpage: true` in the page layout definition.

### Rendering Elements from a Global Page

Use the `from_page` option of the `render_elements` helper. Pass an `Alchemy::Page` instance.

~~~ erb
<%# app/views/layouts/application.html.erb %>
<header>
  <%= render_elements only: "header",
        from_page: Alchemy::Page.find_by(page_layout: "header") %>
</header>

<main>
  <%= yield %>
</main>

<footer>
  <%= render_elements only: "footer",
        from_page: Alchemy::Page.find_by(page_layout: "footer") %>
</footer>
~~~

## Publishing

Pages support time-based publishing with two timestamps:

- **`public_on`** — the date and time the page becomes visible to visitors
- **`public_until`** — the date and time the page is automatically unpublished

Editors can set these in the page settings dialog. When a page is published, Alchemy duplicates the draft version's elements into the public version. Visitors always see the public version.

::: tip
Setting `public_on` to a future date schedules the page for publication. Setting `public_until` lets you create time-limited content like promotions or announcements.
:::

## Caching

Page caching is enabled by default. When active, page requests deliver `Cache-Control` headers that browsers, CDNs, and proxies use to cache the page. See the [Configuration guide](configuration#caching) for global cache settings.

::: tip
Set `cache: false` on individual page layouts to disable caching for pages with forms or personalized content.
:::

### Fragment Caching

Use Rails' [fragment caching](https://guides.rubyonrails.org/caching_with_rails.html#fragment-caching) to cache page templates.

~~~ erb
<% cache @page do %>
  <%= render_elements %>
<% end %>
~~~

::: warning
Do not cache page templates that contain forms (contact forms, comment forms, etc.). Rails' CSRF protection token is inside the `<form>` tag and caching it will break form submissions.
:::

## SEO Metadata

Pages have `title`, `meta_description`, and `meta_keywords` attributes for SEO. Editors can set these in the page settings dialog.

::: tip NOTE
Starting with Alchemy 8.1, these attributes have moved to `PageVersion`. This means SEO metadata changes need to be published just like content changes. In Alchemy 8.0, they are still stored directly on the page.
:::

## URL Redirects

When a page's URL changes — because it was renamed or moved in the tree — Alchemy automatically creates a 301 redirect from the old URL to the new one. These redirects can be managed in the admin page settings.

## Translating Page Layout Names

Page layout names are passed through Rails' I18n.

~~~ yaml
# config/locales/alchemy.de.yml
de:
  alchemy:
    page_layout_names:
      contact: Kontakt
      search: Suche
~~~

::: tip
All Alchemy translation keys are scoped under the `alchemy` namespace.
:::
