---
prev: pages
next: ingredients
---

# Elements

Elements are the central building blocks of an Alchemy website. They are reusable content containers - for example, a headline, an image and a text block might form an "article" element. These individual pieces of content within an element are called [ingredients](ingredients).

You define elements and their ingredients in YAML. Editors place them on pages through the admin interface. You control how they are rendered with view partials. See the [About guide](about) for how elements fit into the full content architecture.

## Defining elements

Elements are defined in the `config/alchemy/elements.yml` file. Element definitions are written in [YAML](http://yaml.org).

If this file does not exist yet, create it with the scaffold generator:

~~~ bash
bin/rails g alchemy:install
~~~

The generator also creates the other basic folders and files for setting up your website with Alchemy.

### Example element definition

~~~ yaml
# config/alchemy/elements.yml
- name: article
  unique: true
  ingredients:
    - role: image
      type: Picture
    - role: headline
      type: Text
      as_element_title: true
    - role: copy
      type: Richtext
~~~

The element in this example is named **"article"** and can be placed only once per page (because it is `unique`). It has three ingredients of the following types:

* [Picture](ingredients#picture)
* [Text](ingredients#text)
* [Richtext](ingredients#richtext)

::: tip
By default, the first ingredient's value is used as the preview text in the element's title bar in the admin frontend. If you want a different ingredient to be used instead, add `as_element_title: true` to that ingredient. In the example above, the **"headline"** ingredient would be used instead of **"image"**.
:::

## Element settings

The following settings can be used to define elements in the `elements.yml`.

### name
`String` _required_

A lowercased **unique** name of the element. Separate words need to be underscored. The name is used in the `page_layouts.yml` file to define on which pages the element can be used. It is also the file name of the element's view partial in `app/views/alchemy/elements/`. The name is [translatable](#translating-elements) for the user in the admin frontend.

### unique
`Boolean` (Default: `false`)

Passing `true` means this element can be placed only once on a page. For more fine-grained control, use [amount](#amount) instead.

### hint
`String`

A hint for the user in the admin interface that should be used to describe what the element is used for. The hint is [translatable](#translating-elements) if you provide an I18n translation key instead of a complete sentence. The hint is displayed as a small question mark icon that reveals a tooltip on hover.

### message
`String`

A prominent informational message displayed at the top of the element editor form in the admin interface. You can use simple HTML to add emphasis.

### warning
`String`

A prominent warning message displayed at the top of the element editor form in the admin interface. You can use simple HTML to add emphasis.

### nestable_elements
`Array`

A collection of element names that can be nested into the element.

### taggable
`Boolean` (Default: `false`)

Enables the element to be taggable by the user in the admin frontend.

### fixed
`Boolean` (Default: `false`)

Separates an element from the normal flow. When `true`, the element is only rendered when explicitly requested via the `fixed_elements` scope. See [fixed elements](#rendering-fixed-elements) for more details.

### icon
`String|Boolean`

Controls the icon in the admin UI. Set to `true` to use `<element_name>.svg` or set to a string to use `<string>.svg`, both from `app/assets/images/alchemy/element_icons/` in your app. If not set, Alchemy uses its own default icon.

::: tip
Alchemy uses Remix Icons throughout its admin interface. To keep your custom element icons consistent, download SVG icons from the [Remix Icon website](https://remixicon.com) and place them in the `element_icons` folder.
:::

### amount
`Integer`

Maximum number of top-level instances of this element per page. Once the limit is reached, the element is no longer offered in the "add element" dialog. All elements on the draft version are counted regardless of their published state. Defaults to unlimited. Does not apply to nested elements. For a single instance, use [unique](#unique) instead.

~~~ yaml
- name: hero_banner
  amount: 3
~~~

### compact
`Boolean` (Default: `false`)

Renders the element in a compact UI in the admin editor. Useful for elements that are primarily used as nestable children, like slides in a slider, cards in a card grid, or items in a gallery.

~~~ yaml
- name: slide
  compact: true
  ingredients:
    - role: image
      type: Picture
~~~

### searchable
`Boolean` (Default: `true`)

Include this element's ingredients in the fulltext search index. Set to `false` for elements that contain sensitive data or purely controlling values like CSS class names, accordion titles, or slider timing configurations.

### deprecated
`Boolean|String` (Default: `false`)

Mark this element as deprecated. Set to `true` to use a deprecation notice from I18n, or provide a custom message string directly.

~~~ yaml
- name: old_element
  deprecated: true

- name: legacy_widget
  deprecated: "Use the new_widget element instead."
~~~

When set to `true`, Alchemy looks up the notice via I18n:

~~~ yaml
# config/locales/en.yml
en:
  alchemy:
    element_deprecation_notices:
      old_element: "This element is outdated. Please use new_element instead."
~~~

### ingredients
`Array`

A collection of ingredients the element contains. An ingredient has to have a `role` (unique per element) and a `type`.

::: tip
Have a look at the [ingredients guide](ingredients) to get more information about available ingredient types.
:::

## Available elements

Before you can use elements on pages, you need to define which page layouts they can be placed on.

Open `config/alchemy/page_layouts.yml` and add the element name to the list of available elements for a page layout.

~~~ yaml
- name: standard
  elements: [article]
  autogenerate: [article]
~~~

You can now place the article element on any page with the `standard` page layout.

Any new pages created with the `standard` layout will automatically have the article element.

## Nestable elements

Elements can be nested inside other elements. Define the allowed children in your `elements.yml` file.

### Example

~~~ yaml
- name: article
  ingredients:
    - role: headline
      type: Text
  nestable_elements:
    - text
    - picture

- name: text
  ingredients:
    - role: text
      type: Richtext

- name: picture
  ingredients:
    - role: text
      type: Picture
~~~

::: tip
Nested elements can also have `nestable_elements`. Just don't get too crazy with it, though.
:::

### Rendering nested elements

Use the `render` helper to render all nested elements as a collection.

~~~ erb
<%= element_view_for(article) do |el| %>
  <h3><%= el.render :headline %></h3>

  <div class="text-blocks">
    <%= render article.nested_elements %>
  </div>
<% end %>
~~~

You can also filter nested elements by name.

~~~ erb
<%= element_view_for(article) do |el| %>
  <h3><%= el.render :headline %></h3>

  <div class="text-blocks">
    <%= render article.nested_elements.named(:text) %>
  </div>

  <div class="pictures">
    <%= render article.nested_elements.named(:picture) %>
  </div>
<% end %>
~~~

Or render a single nested element.

~~~ erb
<%= element_view_for(article) do |el| %>
  <h3><%= el.render :headline %></h3>

  <div class="picture">
    <%= render article.nested_elements.find_by(name: :picture) %>
  </div>

  <div class="text-blocks">
    <%= render article.nested_elements.where(name: :text) %>
  </div>
<% end %>
~~~

## Ingredient groups

Ingredients can be visually grouped in the admin editor using the `group` property on ingredient definitions.

~~~ yaml
- name: product
  ingredients:
    - role: title
      type: Text
    - role: description
      type: Richtext
    - role: css_class
      type: Select
      group: settings
    - role: width
      type: Text
      group: settings
~~~

Grouped ingredients are rendered as collapsible sections in the element editor. Ingredients without a `group` appear ungrouped at the top.

::: tip
Use ingredient groups sparingly. Editors should see all content-related ingredients at once without having to expand sections. Groups are best suited for configuration or secondary options that are not part of the main content, such as CSS classes, display settings, or layout options.
:::

Group names can be translated via I18n.

~~~ yaml
# config/locales/en.yml
en:
  alchemy:
    element_groups:
      settings: Settings
      product:
        settings: Display Options
~~~

## Tagging

Elements are taggable. To enable it, add `taggable: true` to the element's definition.

~~~ yaml
- name: article
  taggable: true
  ingredients:
    - role: image
      type: Picture
    - role: headline
      type: Text
      as_element_title: true
    - role: copy
      type: Richtext
~~~

Tags are a collection on the `element` object. `element.tag_list` returns an array of tag names.

~~~ erb
<%= element.tag_list.join(', ') %>
~~~

Alchemy uses the [gutentag](https://github.com/pat/gutentag) gem, so please refer to the github [README](https://github.com/pat/gutentag/blob/master/README.md) or the [Wiki](https://github.com/pat/gutentag/wiki) for further information.

## Validations

You can enable validations for your ingredients. They behave like the Rails model validations.

Supported validations are:

* `presence`
* `uniqueness`
* `format`

The `format` validator needs to have a [regular expression](http://rubular.com) or a predefined matcher string as its value.

Predefined format matchers are listed in `config/alchemy/config.yml`. You can also add your own matchers there.

### Format matchers

~~~ yaml
# config/alchemy/config.yml
format_matchers:
  email: !ruby/regexp '/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/'
  url: !ruby/regexp '/\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix'
~~~

### Example

~~~ yaml
- name: person
  ingredients:
    - role: name
      type: Text
      validate:
        - presence: true
    - role: email
      type: Text
      validate:
        - format: email
    - role: homepage
      type: Text
      validate:
        - format: !ruby/regexp '/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/']
~~~

The `email` ingredient gets validated against the predefined `email` matcher in the `config.yml`.

The `homepage` ingredient is matched against the given regexp.

### Multiple validations

Ingredients can have multiple validations.

~~~ yaml
- name: person
  ingredients:
    - role: name
      type: Text
      validate:
        - presence: true
        - uniqueness: true
        - format: name
~~~

Validations are evaluated in the order they are defined.

The name ingredient will be validated for `presence` first, then for `uniqueness`, and finally against its `format`.

## Rendering

### Generating partials

Each element has a view partial (a [Rails partial](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials)) that lives in `app/views/alchemy/elements/`.

You don't need to create these files yourself. Use the Rails generator to create them.

~~~ bash
bin/rails g alchemy:elements --skip
~~~

The `--skip` flag skips files that already exist.
The `--force` flag will overwrite your element view partials automatically.

::: tip
You can pass `--template-engine` or `-e` as an argument to use `haml`, `slim` or `erb`.
The default template engine depends on your settings in your Rails host app.
:::

The generator will create partials for each element in your `app/views/alchemy/elements` folder.

For the article element from the example above, the generator creates `_article.html.erb`. The generated code serves as a starting point that you can customize to fit your needs.

### Page layouts

With the article element associated with the 'standard' page layout, it can be rendered in the layout partial `app/views/alchemy/page_layouts/_standard.html.erb`.

~~~ erb
...
<div class="row">
  <%= render_elements %>
</div>
...
~~~

This renders all elements from the current page.

::: tip
Pages must be published for elements to be rendered.

If you aren't seeing content you created in the admin interface, make sure elements are saved and you click the "Publish current page content" button from the edit page admin view.
:::

#### Render only specific elements

Sometimes you only want to render specific elements on a specific page and maybe exclude some elements.

~~~ erb
<body>
  <header><%= render_elements only: 'header' %></header>

  <main>
    <%= render_elements except: %w(header footer) %>
  </main>

  <footer><%= render_elements only: 'footer' %></footer>
</body>
~~~

#### render_elements options

The `render_elements` helper accepts several options:

* **only** - Render only elements with these names
* **except** - Render all elements except these names
* **from_page** - Render elements from a different page. Accepts a page layout name as a `String`, an `Array` of page layout names, or an `Alchemy::Page` instance
* **count** - Limit the number of rendered elements
* **offset** - Skip the first N elements
* **random** - Randomize the order of elements
* **fixed** - When `true`, render only fixed elements. See [rendering fixed elements](#rendering-fixed-elements)

#### Render elements from other pages

A common use case is to have global pages for header and footer parts.
~~~ yaml
# config/alchemy/elements.yml
- name: header
  hint: Navigation bar at the top of every page
  ingredients:
    # ...

- name: footer
  hint: Footer section at the bottom of every page
  ingredients:
    # ...

# config/alchemy/page_layouts.yml

- name: header
  unique: true
  elements: [header]
  autogenerate: [header]
  layoutpage: true

- name: footer
  unique: true
  elements: [footer]
  autogenerate: [footer]
  layoutpage: true
~~~

These can be rendered in your `application.html.erb` file.

~~~ erb
<!DOCTYPE html>
<html lang="<%= @page.language_code %>">
  <head>
    ...
  </head>

  <body>
    <header><%= render_elements from_page: 'header' %></header>

    <main>
      <%= yield %>
    </main>

    <footer><%= render_elements from_page: 'footer' %></footer>

    <%= render "alchemy/edit_mode" %>
  </body>
</html>
~~~

#### Rendering fixed elements

Often you have a separate section on one page (like a sidebar) or a global section to be rendered on every page (like a navbar or footer).

If you configure those elements as `fixed: true` in `elements.yml`, then they'll be separated from the general collection of elements and will be displayed in a separate tab in the admin elements section.

~~~ yaml {3}
- name: sidebar
  unique: true
  fixed: true
  ingredients:
    - role: name
      type: Text
      # ...
~~~

You can render fixed elements using `render_elements` with the `fixed` option.

~~~ erb
<aside>
  <%= render_elements fixed: true, only: 'sidebar' %>
</aside>
~~~

You can also access them directly via the page.

~~~ erb
<%= render @page.fixed_elements.named('sidebar') %>
~~~

### Element views

The Alchemy element generator creates a basic view partial for each element. This is where you control how the element's content is rendered on your website.

~~~ erb
<%= element_view_for(element) do |el| %>
  <h3><%= el.render :headline %></h3>
  <div class="row">
    <div class="large-6 columns">
      <p>
        <%= el.render :image %>
      </p>
    </div>
    <div class="large-6 columns">
      <p>
        <%= el.render :text %>
      </p>
    </div>
  </div>
<% end %>
~~~

The `element_view_for` helper wraps the content in a `div` by default. You can change the wrapping tag with the `tag` argument, or pass `false` to disable wrapping entirely.

#### Block helper methods

Besides `el.render`, the block helper provides additional methods for accessing ingredient data.

~~~ erb
<%= element_view_for(element) do |el| %>
  <%= el.render :headline %>

  <% if el.has?(:image) %>
    <%= el.render :image %>
  <% end %>

  <span class="date"><%= el.value(:date) %></span>
<% end %>
~~~

* **`el.render :role`** - Renders the ingredient's view component (the standard way to display ingredients)
* **`el.value(:role)`** - Returns the raw value without any view component wrapping
* **`el.has?(:role)`** - Returns `true` if the ingredient has a non-blank value
* **`el.ingredient_by_role(:role)`** - Returns the ingredient record directly

Use `el.ingredient_by_role` when you need to access ingredient attributes beyond the plain value. For example, a Page ingredient has a `page` method that returns the actual `Alchemy::Page` record, which you can use to build custom links.

~~~ erb
<%= element_view_for(element) do |el| %>
  <% page_ingredient = el.ingredient_by_role(:linked_page) %>
  <% if page_ingredient&.page %>
    <%= link_to page_ingredient.page.name, show_alchemy_page_path(page_ingredient.page) %>
  <% end %>
<% end %>
~~~

#### Pass options to the element wrapper

You can pass additional arguments to add or change any html attributes of the wrapper.

~~~ erb
<%= element_view_for(element, tag: 'li', class: 'red', id: 'my_unique_id') do |el| %>
  ...
<% end %>
~~~

#### Pass options to the ingredient view

You can pass options to the ingredient view.

~~~ erb
<%= element_view_for(element) do |el| %>
  <%= el.render :image, {size: '200x300'}, class: 'image-large' %>
<% end %>
~~~

::: tip
Instead of passing the `size` of an image inline, you should consider using static [ingredient settings](ingredients#individual-ingredient-settings) instead.
:::

The first hash is the `options`, the second is the `html_options` passed to the ingredient's wrapper.
If you only want to pass `html_options`, you need to pass an empty hash as the first argument.

~~~ erb
<%= element_view_for(element) do |el| %>
  <%= el.render :image, {}, class: 'image-large' %>
<% end %>
~~~

## Translating elements

Element and ingredient names are passed through Rails' [I18n](http://guides.rubyonrails.org/i18n.html) library.
You can translate them in your `config/locales` language yml file.

~~~ yaml
de:
  alchemy:
    element_names:
      contact_form: Kontaktformular
      search: Suche
    ingredient_roles:
      headline: Überschrift
~~~

Ingredient roles can also be translated per element.
This is useful when the same role name needs different labels depending on the element.

~~~ yaml
de:
  alchemy:
    element_names:
      contact_form: Kontaktformular
    ingredient_roles:
      color: Farbe
      contact_form:
        color: Button Farbe
~~~

## Admin UI

### Re-arranging elements on a page

Collapsed elements can be re-arranged by clicking and dragging the icon to the left of the element title.

You can't re-arrange an expanded element, you need to collapse it first.

### Using the clipboard

The clipboard holds elements that have been copied or cut. The most common use case is to copy or move elements from one page to another.

You can use the icons to copy and cut a specific element from its expanded state.

You can view the contents of the clipboard using the icon at the top of the elements bar.

When adding a new top-level element, the "Paste from clipboard" tab will be visible if the clipboard is storing any elements.
