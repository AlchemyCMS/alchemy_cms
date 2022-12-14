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
2. The `<element_name>_editor` renders form fields in the admin for the editors _deprecated since Alchemy 4.4_

::: warning
The element editor partials are deprecated and will be removed from Alchemy 5. As of Alchemy 4.4 the generator will not generate them for you anymore.
:::

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
*But*, you don't need to re-run the installer for your changes to be picked up in the admin interface.
Re-running the views generator without the skip flag (`bin/rails g alchemy:elements`) can over-write your element view partials to include the content changes if you so desire.
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

  A hint for the user in the admin that should be used to describe what the element is used for. The hint is [translatable](#translating-elements) if you provide an I18n translation key instead of a complete sentence. The hint itself will be displayed as a small question mark icon and will reveal a tooltip once hovered by the user.

* **message** `String` _since Alchemy 4.4_

  A prominent informational message displayed at the top of the element editor form in the admin that can be used to give your user additional information. You can even use simple html to add some emphasis to your message.

* **warning** `String` _since Alchemy 4.4_

  A prominent warning message displayed at the top of the element editor form in the admin that can be used to warn your user about something. You can use simple html to add even more emphasis to your warning.

* **nestable_elements** `Array`

  A collection of element names that can be nested into the element.

* **taggable** `Boolean` (Default: `false`)

  Enables the element to be taggable by the user in the admin frontend.

* **fixed** `Boolean` (Default: `false`)

  Used to separate an element from the normal flow. When `true`, the element is rendered on the page only with the explicit call of the `fixed_elements` scope. See [fixed elements](/elements.html#render-a-group-of-elements-on-a-fixed-place-on-the-page) for more details.

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
The `--skip` flag skips files that already exist
:::

::: tip
You can pass `--template-engine` or `-e` as an argument to use `haml`, `slim` or `erb`.
The default template engine depends on your settings in your Rails host app.
:::

The generator will create two files for each element in your `app/views/alchemy/elements` folder.

According to the first example, the article element, the generator will create the `_article_view.html.erb` and `_article_editor.html.erb` (_deprecated since Alchemy 4.4_) files.

* The element's view file `_article_view.html.erb` gets rendered, when a user requests your webpage.
* The element's editor file `_article_editor.html.erb` gets rendered, when you edit the page in the admin frontend.  _deprecated since Alchemy 4.4_

::: warning
The element editor partials are deprecated and will be removed from Alchemy 5. As of Alchemy 4.4 the generator will not generate them for you anymore.
:::

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

::: tip
Pages must be published for Elements to be associated and rendered.

If you aren't seeing content you created in the admin interface, make sure elements are saved and and you click the "Publish current page content" button from the edit page admin view.
:::

### Render only specific elements

Sometimes you only want to render specific elements on your page and maybe exclude some elements.

~~~ erb
<body>
  <header><%= render_elements only: 'header' %></header>

  <main>
    <%= render_elements except: %w(header footer) %>
  </main>

  <footer><%= render_elements only: 'footer' %></footer>
</body>
~~~

::: tip
The above example uses _elements_ (not pages) called `header` and `footer`. If these elements need to be editable in the Admin interface, you should associate these elements with their own [page_layouts](#defining-page-layouts).
:::


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

### Render a group of elements on a fixed place on the page

Often you have a separate section on one page (like a sidebar) or a global section to be rendered on every page (like a navbar or footer).

If you tag those elements as `fixed: true` in `elements.yml`, then they'll be separated from the general collection of elements and will be displayed separately in a separate tab in the admin elements section.

~~~ yaml {3}
- name: sidebar
  unique: true
  fixed: true
  contents:
    - name: name
      type: EssenceText
      ...
~~~

~~~ erb
<% @page.fixed_elements.each do |element| %>
  <%= render_element(element) %>
<% end %>
~~~

::: tip INFO
Fixed elements replace [Cells](/cells.html) in Alchemy > 4.2.
:::

As `fixed_elements` is an a active record scope you can also filter by `where(name: 'your_element')` or use the `named('your_element')` scope. To gain some extra efficiency from Rails you could also use the collection rendering shortcut

~~~ erb
<%= render @page.fixed_elements.named('sidebar') %>
~~~

::: tip NOTE
You need to use the elements view partial name instead of the element local variable in your child element views. Ie. `sidebar_view` instead of `element`.
:::


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
  <%= el.render :image, {size: '200x300'}, class: 'image-large' %>
<% end %>
~~~

::: tip
Instead of passing the `size` of an image into the `EssencePicture` as shown above, you should consider to use static [content settings](essences.html#individual-essence-settings) instead.
:::

The first hash is the `options` the second one the `html_options` passed to the wrapper of the content.
If you only want to pass `html_options` you need to pass an empty hash as second argument.

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
