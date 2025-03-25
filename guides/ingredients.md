---
prev: elements
next: render_images
---

# Ingredients

## Overview

Ingredients store the actual content of your site. They are stored as instances of `Alchemy::Ingredient` subclasses on each `Alchemy::Element` instance.

Alchemy uses Rails [Single Table Inheritance](https://guides.rubyonrails.org/association_basics.html#single-table-inheritance-sti) to store the values in the same table.

Alchemy comes with a lot of predefined ingredients for the regular needs of a website project. Combine them like a chemestry kit into [elements](elements).

Ingredients are Rails models. It is pretty easy to [add your own ingredient class](how_to_create_custom_ingredients) as well.

## Definition

Ingredients are defined as `ingredients` on an [element definition](elements#defining-elements).

### Global ingredient settings

When defining ingredients, you need to provide a `role` and `type`. You can set hints and default values as well.

~~~ yaml
# config/alchemy/elements.yml
- name: article
  ingredients:
    - role: headline
      type: Headline
      hint: This is the headline
    - role: color
      type: Text
      settings:
        input_type: color
    - role: copy
      type: Richtext
      default: Lorem ipsum dolor
      as_element_title: true
~~~

* **role** `String` _required_

  A lowercased **unique** (per element) role of the ingredient. Separate words needs to be underscored.

* **type** `String` _required_

  An type this ingredient is of. Alchemy has lots of built in ingredients for [simple text](#text), [rich text](#richtext), [images](#picture), [booleans](#boolean) and more.

* **hint** `String|Symbol|Boolean`

  A hint for the user in the admin frontend that describes what the ingredient is used for. The hint is translatable if you provide an I18n translation `Symbol` instead of a `String`. You may also set it to `true` to default to the I18n key `alchemy.ingredients_hints.your_ingredient_role`.

* **default** `String`

  The default text to prefill newly created elements. You may also use a symbol to set it to the I18n key `alchemy.default_ingredients_texts.your_ingredient_role`

* **as_element_title** `Boolean`

  For the displayed element title, the first ingredient is used. Use this setting to override this behaviour and show other ingredient as element title.

* **settings** `Hash`

  A set of options to configure the ingredient. Each ingredient has its own set of options listed below.

### Individual ingredient settings

Each ingredient type can have its own type of settings.

To configure these settings you have to pass them into its `settings` key in the `elements.yml`.

~~~ yaml {5-6}
- name: my_element
  ingredients:
    - role: headline
      type: Text
      settings:
        linkable: true
~~~

## Text

Stores plain text of 255 chars max.

Use this for a headline, or a product name. The editor is renderd as a single lined input field. The view output will be sanitized and HTML escaped.

### Settings

* **linkable** `Boolean`

  If set to `true`, the user can add a link to the text.

* **input_type** `String`

  Change the [input type](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#Form_%3Cinput%3E_types) of the form field displayed in the editor.

### Example

~~~ yaml
- name: button
  type: Text
  settings:
    linkable: true
~~~

## Headline

Stores headline text of 255 chars max.

Use this for HTML headings. The editor is renderd as a single lined input field with level and optional size selects. The view output will be a heading element.

### Settings

* **anchor** `Boolean` or the `String` `from_value`

  If set to `true`, the user can add a custom anchor to the headline.
  If set to `from_value` the anchor will be created from the value.
  The anchor will be added as `id` to the heading tag.

* **levels** `Array` of `Integer`s

  Set the available [heading levels](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/Heading_Elements) that the editor can choose from.
  By default it is 1 to 6.

* **sizes** `Array` of `Integer`s

  Optionally add a listy of sizes that the editor can choose a heading css size. Added as class (`.h2`) to the heading element. Use this of

### Example

~~~ yaml
- name: headline
  type: Headline
  settings:
    levels: [2, 3]
    sizes: [1, 2]
~~~

## Richtext

Used to store paragraphs of formatted text.

The editor is rendered as a textarea with embedded Tinymce Editor.

### Settings

You can customize the Tinymce editor of a single element instance.

* **tinymce** `Hash`

### Example

~~~ yaml
- name: text
  type: Richtext
  settings:
    tinymce:
      style_formats:
        - title: 'Subheadline'
          block: 'h3'
~~~

::: tip INFO
See the [Tinymce customization guide](how_to_customize_tinymce) for all available options
:::

## Picture

Store references to pictures the editor assigns from the library.

The editor partial is rendered as a picture editor with a lot of options (i.e. image cropper).

The view partial renders the assigned picture, resizes it and crops it if needed.

::: tip INFO
See the [rendering images](render_images) guide for further information on the powerful image rendering engine of Alchemy.
:::

### Settings

* **size** `String`

  The size the image should be downsized to. I.e. 400x300

* **crop** `Boolean` (default: false)

  Crop the image to given size. This also enables the build in cropper tool.

* **srcset** `Array<String>`

  A list of sizes of this image uses as sources list. Best used with the `sizes` setting for implementing responsive images.

* **sizes** `Array<String>`

  A list of screen sizes the image sources should be used for. Best used with the `srcset` setting for implementing responsive images.

* **linkable** `Boolean`

  If set to `false`, the user cannot add a link to the picture.

## Datetime

Use this to store a `DateTime` value. Renders a datepicker in the editor partial.

The view output is passed through Rails' I18n Library, so it is fully localizable.

### Settings

* **date_format** `String|Symbol`
  Either a `String` with the format of [Rubys `strftime`](https://ruby-doc.org/stdlib-2.6.1/libdoc/date/rdoc/Date.html#method-i-strftime) or a `Symbol` of a [date/time format](https://guides.rubyonrails.org/i18n.html#adding-date-time-formats) defined in your locale files.

## Html

Useful to store HTML code (i.e. a embed, or tracking code).

::: warning
The view renders the raw, not sanitized or escaped output.
**So be careful!**
:::

## Boolean

Stores a `Boolean` value in the database. Renders a checkbox in the editor partial.

## Select

Renders a select box in the editor partial and stores the value as `String`.

Useful for letting your user select from a limited set of choices.

### Settings

* **select_values** `Array`

  A list of values your users can select from. Use [a two dimensional array](https://guides.rubyonrails.org/form_helpers.html#the-select-and-option-tags) for having value and text pairs.

### Example

~~~ yaml
- name: width
  type: Select
  settings:
    select_values: ['200', '300', '400']
~~~

::: tip
If you need dynamic values (ie, a from a product catalogue), please [create a custom ingredient class](how_to_create_custom_ingredients) that provides the values.
:::

## Link

Stores a url in the database. Useful for linking things, where the editor should not set the linked text itself.

::: tip
If you want the linked text to be editable by the editor use the [**Text**](#text) with `linkable: true` option instead.
:::

## Number

Stores a number in the database. Useful for slider durations, price, lengths, etc. The number value gets translated via Rails' [`number_to_human`](https://api.rubyonrails.org/classes/ActionView/Helpers/NumberHelper.html#method-i-number_to_human) helper.

### Settings

* **input_type** `String|Symbol`
  The input type to render the editor with. Defaults to `number`. Can be set to `range` instead.
* **step** `Integer|Decimal`
  The step on the editor input.
* **min** `Integer|Decimal`
  The minimum number allowed on the editor input.
* **max** `Integer|Decimal`
  The maximum number allowed on the editor input.
* **unit** `String`
  The unit displayed on the editor input addon. Also used as `unit` for the `number_to_human` helper.

## Page

References an [Alchemy::Page](pages).

Renders a select box in the editor partial.

Useful for contact form follow up pages or other use cases where you want to reference another page.

### Example

~~~ yaml
- name: contact_form
  ingredients:
    - role: follow_up_page
      type: Page
~~~

## Rendering ingredients within your element

Similar to [rendering elements within layouts](elements.html#render_elements_in_your_layout), ingredients are rendered on an element.

Page layouts use the `<%= render_elements %>` helper to load an elements partial, elements use the `<%= element_view_for %>` helper to expose a block that makes it easy to access the ingredients (instances of `Alchemy::Ingredient` subclasses) of the element.

For example. With an `article` element like this:

~~~ yaml
# config/alchemy/elements.yml
- name: article
  ingredients:
    - role: headline
      type: Text
    - role: color
      type: Text
      settings:
        input_type: color
    - role: copy
      type: Richtext
~~~

The `_article.html.erb` template generated by `rails alchemy:elements --skip` would look like this:

~~~erb
<%- cache(article) do -%>
  <%= element_view_for(article) do |el| -%>
    <div class="headline">
      <%= el.render :headline %>
    </div>
    <div class="color">
      <%= el.render :color %>
    </div>
    <div class="copy">
      <%= el.render :copy %>
    </div>
  <%- end -%>
<%- end -%>
~~~

Note how `element_view_for` allows you to call `el.render` on ingredients within the block.

::: tip
`element_view_for` wraps the block in a `<div>` with a set ID and class by default, but this is [customizeable](https://github.com/AlchemyCMS/alchemy_cms/blob/main/app/helpers/alchemy/elements_block_helper.rb#L137) if you pass in arguments:

`<%= element_view_for(article, tag: :span, id: 'custom_id', class: 'custom_class') do |el| -%>`
:::

Without using the `element_view_for` helper, you can still access ingredients:

`article.ingredient_by_role('headline')&.value`

But the `el.render` helper takes care of generating the appropriate DOM elements to display the ingredient based on its type. It is recommended you rely on these helpers unless you are comfortable with the structure of the ingredient model you are trying to render.

Just like `element_view_for`, you can pass `options` and `html_options` to `el.render`:

~~~erb
<%= el.render :headline, options = {}, html_options = {} %>
~~~

You can check out the [`ElementViewHelper#render` helper](https://github.com/AlchemyCMS/alchemy_cms/blob/b8cc62493693a070f7457081760708bf28c13e34/app/helpers/alchemy/elements_block_helper.rb#L31) for details.

::: warning NOTE
Options are not universally applied by all element types. For example, `ElementRichText` ignores `html_options` since it's already in HTML format and isn't wrapped in any special div. And you can't prevent the `ElementPicture` from generating an `<img>` tag.
:::

### Options

The `options = {}` hash is used for formatting the child elements' tags. You can pass `false` to not include tags inside the wrapper element. For more, see the source code [here](https://github.com/AlchemyCMS/alchemy_cms/blob/56e95a07446fb6832676acfc1e8c7047d1b80495/app/helpers/alchemy/elements_block_helper.rb#L128) and [here](https://github.com/AlchemyCMS/alchemy_cms/blob/main/app/helpers/alchemy/elements_helper.rb#L193)

### Html_options

The `html_option = {}` are:
* `:tag` - The HTML tag to be used for the wrapping element
* `:id` - The wrapper tag's DOM ID.
* `:class` - The wrapper tag's DOM class.
