---
prev:
  text: Pages
  link: pages
next:
  text: Rendering Images
  link: render_images
---

# Menus

Alchemy uses a dedicated menu system that is separate from the page tree. Menus are managed through **nodes** — tree-structured entries that can link to Alchemy pages, external URLs, or act as grouping labels.

This separation gives editors full control over navigation structure without being constrained by the page hierarchy. A page can appear in multiple menus, or not appear in any menu at all.

## Defining Menus

Menu types are defined in the `config/alchemy/menus.yml` file. The installer creates this file with two default menus.

~~~ yaml
# config/alchemy/menus.yml
- main_menu
- footer_menu
~~~

Each entry is a menu type name. Alchemy creates a root node for each menu type per language. Editors then build the menu tree by adding child nodes in the admin interface.

## Generating Menu Partials

Alchemy provides a generator that creates view partials for all defined menus.

~~~ bash
bin/rails g alchemy:menus
~~~

For each menu type, the generator creates two partials:

| File | Purpose |
|------|---------|
| `app/views/alchemy/menus/<menu_type>/_wrapper.html.erb` | The outer container (e.g. `<ul>`) |
| `app/views/alchemy/menus/<menu_type>/_node.html.erb` | A single menu item (e.g. `<li>`) |

## Rendering Menus

Use the `render_menu` helper in your layout to render a menu.

~~~ erb
<%# app/views/layouts/application.html.erb %>
<nav>
  <%= render_menu "main_menu" %>
</nav>

<footer>
  <%= render_menu "footer_menu" %>
</footer>
~~~

The helper finds the root node for the given menu type in the current language and renders the wrapper partial. You can pass custom options that are available in your partials.

~~~ erb
<%= render_menu "main_menu", class: "navbar" %>
~~~

## Customizing Menu Partials

### The Wrapper Partial

The wrapper partial receives the root node as `menu` and any options you passed to `render_menu`.

~~~ erb
<%# app/views/alchemy/menus/main_menu/_wrapper.html.erb %>
<% cache [menu, @page, Alchemy::Current.preview_page?] do %>
  <ul class="nav">
    <%= render partial: menu.to_partial_path,
      collection: menu.children.includes(:page, :children),
      locals: { options: options },
      as: 'node' %>
  </ul>
<% end %>
~~~

### The Node Partial

The node partial receives each node and renders it as a menu item. Child nodes are rendered recursively.

~~~ erb
<%# app/views/alchemy/menus/main_menu/_node.html.erb %>
<% cache [node, @page, Alchemy::Current.preview_page?] do %>
  <%= content_tag :li, class: ['nav-item', node.children.any? ? 'dropdown' : nil].compact do %>
    <%= link_to_if node.url,
      node.name,
      Alchemy::Current.preview_page? ? 'javascript: void(0)' : node.url,
      class: ['nav-link', current_page?(node.url) ? 'active' : nil].compact,
      title: node.title,
      target: node.external? ? '_blank' : nil,
      rel: node.nofollow? ? 'nofollow' : nil %>
    <% if node.children.any? %>
      <ul class="dropdown-menu">
        <%= render node.children.includes(:page, :children), as: 'node' %>
      </ul>
    <% end %>
  <% end %>
<% end %>
~~~

Customize these partials to match your site's markup and CSS framework.

## Node Properties

Each node has the following properties that editors can set in the admin interface.

### Page

An optional Alchemy page. When set, the node's name and URL are taken from the page automatically.

### Name

A custom label. Required when no page is linked. When a page is linked, the page name is used unless a custom name is provided.

### Title

An optional title attribute for the link tag.

### URL

An optional external URL. When a page is linked, the page's URL is used instead.

### External

Marks the link as external. When `true`, the link opens in a new tab (`target="_blank"`).

### Nofollow

When `true`, adds `rel="nofollow"` to the link.

## Translating Menu Names

Menu type names are translated through I18n. These names appear as root node labels in the admin interface.

~~~ yaml
# config/locales/alchemy.de.yml
de:
  alchemy:
    menu_names:
      main_menu: Hauptnavigation
      footer_menu: Fusszeile
~~~