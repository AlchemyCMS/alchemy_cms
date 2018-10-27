---
prev: /cells.html
next: /essences.html
---

# Elements

## Overview

Elements are reusable sets of contents that belong together, visually and contextually.

Imagine you bundle a headline, a text block and a picture - this is a typical element, maybe you want to call it an "article".

Some people speak of widgets, blocks or components. All these are elements in Alchemy. Elements can be nested into each other and are the key of Alchemy's flexible content architecture.

They give you a powerful tool to build the CMS you need.

The contents of an element are of a specific [essence](essences.html). Each essence represents a data type that store values in the database.

## Templates

Elements have two templates (they are called [partials in Rails](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials)).

1. The `<element_name>_view` represents the element on your website
2. The `<element_name>_editor` renders form fields in the admin for the editors

They live in `app/views/alchemy/elements/`.

::: tip NOTE
You don't need to create the files yourself. Use [the built in generator](#generating-the-partials) to let Alchemy generate them for you.
:::

## Defining elements

Elements are defined in the `config/alchemy/elements.yml` file. Element definitions are written in [YAML (YAML Ain't Markup Language)](http://yaml.org)

If this file does not exist yet, use the scaffold generator to do that now:

~~~ bash
bin/rails g alchemy:install
~~~

The generator also creates all the other basic folders and files for setting up your website with Alchemy.

::: warning NOTE
The element definitions are cached. Please restart the server after editing the `elements.yml`.
:::

### Example element definition

~~~ yaml
# config/alchemy/elements.yml
- name: article
  unique: true
  contents:
  - name: image
    type: EssencePicture
  - name: headline
    type: EssenceText
    as_element_title: true
  - name: copy
    type: EssenceRichtext
~~~

The element in this example is named **"article"** and can be placed only once per page. It has three contents of the following types:

* [EssencePicture](essences.html#essencepicture)
* [EssenceText](essences.html#essencetext)
* [EssenceRichtext](essences.html#essencerichtext)

::: tip
You can select which content will be used for the preview text in the element's title bar in the admin frontend by adding `as_element_title: true` to the desired content. In the example above, the **"headline"** content would be used.
:::

### Element settings

The following settings can be used to define elements in the `elements.yml`.

* **name** `String` _required_

  A lowercased **unique** name of the element. Separated words needs to be underscored. The name is used in the `page_layouts.yml` file to define on which pages the element can be used. It is also part of the `app/views/alchemy/elements` view partials file names. The name is [translatable](#translating-elements) for the user in the admin frontend.

* **unique** `Boolean` (Default: `false`)

  Passing `true` means this element can be placed only once on a page.
* **hint** `String`

  A hint for the user in the admin frontend that describes what the element is used for. The hint is [translatable](#translating-elements) if you provide an I18n translation key instead of a complete sentence.

* **nestable_elements** `Array`

  A collection of element names that can be nested into the element.

* **taggable** `Boolean` (Default: `false`)

  Enables the element to be taggable by the user in the admin frontend.

* **contents** `Array`

  A collection of contents the element contains. A content has to have a `name` (unique per element) and a `type`.

::: tip
Have a look at the [essences guide](/essences.html) to get more informations about available essence types.
:::

In the following examples you will see how to use these settings.

In the code examples of the partials we use the [slim template engine](http://slim-lang.com) instead of [ERB](http://en.wikipedia.org/wiki/ERuby) to keep the markup short and easy to understand.

## Nestable elements

You are able to nest elements into other elements.

Just define nestable elements in your `elements.yml` file.

### Example

~~~ yaml
- name: article
  contents:
  - name: headline
    type: EssenceText
  nestable_elements:
  - text

- name: text
  contents:
  - name: text
    type: EssenceRichtext
~~~

::: warning NOTE
Nested elements can also have `nestable_elements`. Just don't get too crazy with it, though.
:::

## Rendering nested elements

Use the `render_element` helper to render each nested element.

~~~ erb
<%= element_view_for(element) do |el| %>
  <h3><%= el.render :headline %></h3>

  <div class="text-blocks">
    <% element.nested_elements.each do |nested_element| %>
      <%= render_element nested_element %>
    <% end %>
  </div>
<% end %>
~~~

## Element with tags

Elements are taggable. To enable it, add `taggable: true` to the element's definition.

~~~ yaml
- name: article
  taggable: true
  contents:
  - name: image
    type: EssencePicture
  - name: headline
    type: EssenceText
    as_element_title: true
  - name: copy
    type: EssenceRichtext
~~~

Tags are a collection on the `element` object. `element.tag_list` returns an array of tag names.

~~~ erb
= element.tag_list.join(', ')
~~~

Alchemy uses the [gutentag](https://github.com/pat/gutentag) gem, so please refer to the github [README](https://github.com/pat/gutentag/blob/master/README.md) or the [Wiki](https://github.com/pat/gutentag/wiki) for further informations.

## Element with content validations

You can enable validations for your contents. They behave like the Rails model validations.

Supported validations are

* `presence`
* `uniqueness`
* `format`

The `format` validator needs to have a [regular expression](http://rubular.com) or a predefined matcher string as its value.

There are already predefined format matchers listed in the `config/alchemy/config.yml` file.

It is also possible to add own format matchers there.

### Format matchers

~~~ yaml
# config/alchemy/config.yml
format_matchers:
  email: !ruby/regexp '/\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/'
  url:   !ruby/regexp '/\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix'
~~~

### Example

~~~ yaml
- name: person
  contents:
  - name: name
    type: EssenceText
    validate:
    - presence: true
  - name: email
    type: EssenceText
    validate:
    - format: email
  - name: homepage
    type: EssenceText
    validate:
    - format: !ruby/regexp '/^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/']
~~~

The `email` content gets validated against the predefined `email` matcher in the `config.yml`.

The `homepage` content is matched against the given regexp.

### Multiple validations.

Contents can have multiple validations.

~~~ yaml
- name: person
  contents:
  - name: name
    type: EssenceText
    validate:
    - presence: true
    - uniqueness: true
    - format: name
~~~

The validations are evaluated in the order as they are defined in the list.

At first the name content will be validated for `presence`, then for `uniqueness` and at least against its `format`.

## Assign elements to page layouts

Before you can use elements on pages, you need to define on which page layouts your element can be placed.

So open `config/alchemy/page_layouts.yml` in your text editor and put the name of your new element into the list of available elements for a specific page layout.

~~~ yaml
- name: standard
  elements: [article]
  autogenerate: [article]
~~~

You can now place the article element on each page with page layout `standard`.

All future created pages with page layout `standard` will automatically create the article element for you.

## Generating the partials

After typing the line below in your terminal, the rails generator will create the elements editor and view files.

~~~ bash
bin/rails g alchemy:elements --skip
~~~

::: tip
You can pass `--template-engine` or `-e` as an argument to use `haml`, `slim` or `erb`.
The default template engine depends on your settings in your Rails host app.
:::

The generator will create two files for each element in your `app/views/alchemy/elements` folder.

According to the first example, the article element, the generator will create the `_article_view.html.erb` and `_article_editor.html.erb` files.

* The element's view file `_article_view.html.erb` gets rendered, when a user requests your webpage.
* The element's editor file `_article_editor.html.erb` gets rendered, when you edit the page in the admin frontend.

The generator does not only create these files, it also generates the necessary code for you. Mostly you can take use of the that code and make it nifty by adding some CSS stylings.

## Render elements in your layout

Now that the above 'article' element example is associated with the 'standard' page layout, the element can be rendered on that layout `app/views/alchemy/page_layouts/_standard.html.erb`.

~~~ erb
...
<div class="row">
  <%= render_elements %>
</div>
...
~~~

This renders all elements from current page.

### Render only specific elements

Sometimes you only want to render specific elements on your page and maybe some elements not.

~~~ erb
<body>
  <header><%= render_elements only: 'header' %></header>

  <main>
    <%= render_elements except: %w(header footer) %>
  </main>

  <footer><%= render_elements only: 'footer' %></footer>
</body>
~~~

### Render elements from other pages

A common use case is to have global pages for header and footer parts.

~~~ erb
<body>
  <header><%= render_elements from_page: 'header' %></header>

  <main>
    <%= render_elements %>
  </main>

  <footer><%= render_elements from_page: 'footer' %></footer>
</body>
~~~

Given global pages with `page_layout` "header" and "footer".

## Customizing the view partial

The Alchemy element generator creates the basic html markup for you.

Pretty useful, but maybe not what you need, sometimes. No problem, feel free to customize it. It's yours :).

This is the newer notation for rendering the element's partial:

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

The `element_view_for` helper wraps the inner html code into a `div` element by default. You can pass arguments to the helper to change its rendering behavior:

The second argument `tag` is used for the wrapping html tag. Passing `false` to it means no wrapping at all. Passing the name of any html element to it means the inner html gets wrapped within the given html tag instead of the default `div`.

### Pass options to the element wrapper

You can pass additional arguments to add or change any html attributes of the wrapper.

~~~ erb
<%= element_view_for(element, tag: 'li', class: 'red', id: 'my_unique_id') do |el| %>
  ...
<% end %>
~~~

::: tip
If you want to learn more about the helper methods used in these partials, please have a look at the [Documentation](http://rubydoc.info/search/github/AlchemyCMS/alchemy_cms?q=helper).
:::

### Pass options to the essence view

You can pass options to the essence view.

~~~ erb
<%= element_view_for(element) do |el| %>
  <%= el.render :image, {image_size: '200x300'}, class: 'image-large' %>
<% end %>
~~~

::: tip The first hash is the `options` the second one the `html_options` passed to the wrapper of the content.
If you only want to pass `html_options` you need to pass an empty hash as second argument.
:::

~~~ erb
<%= element_view_for(element) do |el| %>
  <%= el.render :image, {}, class: 'image-large' %>
<% end %>
~~~

::: tip
Not all essences have wrapper tags. A list of all essence views are [here](https://github.com/AlchemyCMS/alchemy_cms/tree/master/app/views/alchemy/essences).
:::

## Translating elements

Element and content names are passed through Rails' [I18n](http://guides.rubyonrails.org/i18n.html) library.
You can translate them in your `config/locales` language yml file.

~~~ yaml
de:
  alchemy:
    element_names:
      contact_form: Kontaktformular
      search: Suche
    content_names:
      headline: Überschrift
~~~

Content names can also be translated related to their element.
This is useful for contents with the same name that should have different translations.

~~~ yaml
de:
  alchemy:
    element_names:
      contact_form: Kontaktformular
    content_names:
      color: Farbe
      contact_form:
        color: Button Farbe
~~~
