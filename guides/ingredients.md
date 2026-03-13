---
prev:
  text: Elements
  link: elements
next:
  text: Pages
  link: pages
---

# Ingredients

Ingredients are the individual content fields within an [element](elements). Each ingredient has a type that determines what kind of data it stores and how it is edited in the admin interface.

Alchemy comes with a set of built-in ingredient types for common needs. You can also [create your own ingredient types](how_to_create_custom_ingredients).

::: tip
The [alchemy-solidus](https://github.com/AlchemyCMS/alchemy-solidus) extension is a good example of custom ingredients in action. It provides `SpreeProduct`, `SpreeTaxon` and `SpreeVariant` ingredient types that associate Alchemy elements with Solidus e-commerce models.
:::

## Global Settings

Ingredients are defined within an [element definition](elements#defining-elements) in `config/alchemy/elements.yml`. Each ingredient requires a `role` and `type`. You can also set hints and default values.

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

### role
`String` _required_

A lowercased **unique** (per element) identifier for the ingredient. Separate words with underscores. The role is used as the label in the admin and is [translatable](i18n#ingredient-roles).

### type
`String` _required_

The ingredient type as a PascalCase class name (e.g. `Text`, `Richtext`, `Picture`). This maps to a class under `Alchemy::Ingredients`, so `Text` resolves to `Alchemy::Ingredients::Text`. Alchemy provides built-in types for [plain text](#text), [rich text](#richtext), [images](#picture), [booleans](#boolean) and more.

### hint
`String|Symbol|Boolean`

A hint for the editor in the admin interface that describes what the ingredient is used for. Set to `true` to use a [translated hint](i18n#hints) from your locale files.

### default
`String`

The default value to prefill newly created elements. You can also use a symbol to reference a [translated default text](i18n#default-ingredient-texts).

### as_element_title
`Boolean`

By default, the first ingredient is used for the element's title in the admin. Use this setting to override that and use a different ingredient instead.

### settings
`Hash`

Type-specific options to configure the ingredient. Each type has its own set of options listed below.

## Text

Stores plain text of 255 characters max.

Use this for headlines, product names, or short labels. The editor renders a single-line input field. The output is sanitized and HTML-escaped.

### Example

~~~ yaml
- name: button
  type: Text
  settings:
    linkable: true
~~~

### Settings

#### linkable
`Boolean`

If set to `true`, the editor can add a link to the text.

#### input_type
`String`

Change the [input type](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input#Form_%3Cinput%3E_types) of the form field displayed to the editor.

#### anchor
`Boolean|String`

Controls the DOM ID (`id` attribute) on the rendered element. Set to `true` to let the editor enter a custom anchor. Set to `from_value` to auto-generate it from the ingredient's value. Set to any other string to use that as a fixed anchor.

## Headline

Stores headline text of 255 characters max.

Use this for HTML headings. The editor renders a single-line input field with level and optional size selects. The view outputs a heading element (`<h1>` through `<h6>`).

### Example

~~~ yaml
- name: headline
  type: Headline
  settings:
    levels: [2, 3]
    sizes: [1, 2]
~~~

### Settings

#### anchor
`Boolean|String`

Controls the DOM ID (`id` attribute) on the heading tag. Set to `true` to let the editor enter a custom anchor. Set to `from_value` to auto-generate it from the headline text. Set to any other string to use that as a fixed anchor.

#### levels
`Array` of `Integer`s

Set the available [heading levels](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/Heading_Elements) the editor can choose from.
Defaults to 1 through 6.

#### sizes
`Array` of `Integer`s

Add a list of visual sizes the editor can choose from. The selected size is added as a CSS class (e.g. `.h2`) to the heading element, allowing you to decouple visual size from semantic level.

## Richtext

Stores paragraphs of formatted text.

The editor renders a textarea with an embedded TinyMCE editor.

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

::: tip
See the [TinyMCE customization guide](how_to_customize_tinymce#per-ingredient-customization) for all available options.
:::

### Settings

#### tinymce
`Hash`

Customize the TinyMCE editor for this ingredient.

## Picture

Stores a reference to a picture from the Alchemy library.

The editor renders a picture selector with cropping options. The view renders the assigned picture, resized and cropped as configured.

::: tip
See the [rendering images](render_images) guide for more on Alchemy's image rendering engine.
:::

### Example

~~~ yaml
- name: hero_image
  type: Picture
  settings:
    size: 1200x600
    crop: true
    srcset: ['400x200', '800x400', '1200x600']
    sizes: ['(max-width: 600px) 400px', '(max-width: 900px) 800px', '1200px']
~~~

### Settings

#### size
`String`

The size to downscale the image to, e.g. `400x300`.

#### crop
`Boolean` (Default: `false`)

Crop the image to the given size. This also enables the built-in cropper tool.

#### srcset
`Array<String>`

A list of image sizes to use as sources. Best used with the `sizes` setting for responsive images.

#### sizes
`Array<String>`

A list of media conditions for the image sources. Best used with the `srcset` setting for responsive images.

#### css_classes
`Array<String>`

CSS classes the editor can choose from. The class labels are [translatable](i18n#picture-css-classes).

~~~ yaml
- name: hero_image
  type: Picture
  settings:
    css_classes: ['left', 'right', 'no_float']
~~~

#### fixed_ratio
`Boolean` (Default: `false`)

If set to `true`, the crop ratio is locked to the aspect ratio of the `size` setting. Requires `crop: true` and a `size` with both dimensions.

#### linkable
`Boolean` (Default: `true`)

If set to `false`, the editor cannot add a link to the picture.

#### upsample
`Boolean` (Default: `false`)

If set to `true`, images smaller than the requested `size` are upscaled.

## Select

Stores a value selected from a list of options. The editor renders a select box. With `multiple: true`, multiple values can be selected and the value is stored as an array.

### Example

~~~ yaml
- name: width
  type: Select
  default: '300'
  settings:
    select_values: ['200', '300', '400']
~~~

### Settings

#### select_values
`Array`

The values the editor can choose from. Use [a two-dimensional array](https://guides.rubyonrails.org/form_helpers.html#the-select-and-option-tags) for separate display text and stored value pairs.

#### display_inline
`Boolean`

If set to `true`, renders the select box inline in the element editor.

#### multiple <Badge type="tip" text="8.1+" />
`Boolean` (Default: `false`)

Allow the editor to select multiple values. When enabled, the value is stored as a JSON array internally. The `value` method returns an array instead of a string.

~~~ yaml
- name: categories
  type: Select
  settings:
    select_values:
      - ['Ruby on Rails', 'rails']
      - ['Single Page App', 'spa']
      - ['Static Site', 'static']
    multiple: true
~~~

Accessing the values in your template:

~~~ erb
<%= element_view_for(element) do |el| %>
  <% el.value(:categories).each do |category| %>
    <span class="badge"><%= category %></span>
  <% end %>
<% end %>
~~~

::: tip
If you need dynamic values (e.g. from a product catalogue), [create a custom ingredient type](how_to_create_custom_ingredients) instead.
:::

## Link

Stores a URL. Useful for linking content where the editor should not set the link text directly.

### Settings

#### text
`String`

Default link text.

::: tip
If you want the link text to be editable, use [Text](#text) with `linkable: true` instead.
:::

## Number

Stores a number value. Useful for prices, durations, quantities, etc.

### Settings

#### input_type
`String|Symbol`

The input type for the editor. Defaults to `number`. Can be set to `range`.

#### step
`Integer|Decimal`

The step increment for the input.

#### min
`Integer|Decimal`

The minimum allowed value.

#### max
`Integer|Decimal`

The maximum allowed value.

#### unit
`String`

The unit label displayed next to the input.

## Color <Badge type="tip" text="8.1+" />

Stores a string value representing a color. Without any settings, the editor renders a free color picker.

Values are not restricted to hex codes -- you can use any string: hex values, CSS color names, CSS custom properties, CSS class names, or any other token your frontend understands.

### Predefined Colors

Use the `colors` setting to offer a palette of predefined options:

~~~ yaml
- name: brand_color
  type: Color
  settings:
    colors:
      - "#ff0000"
      - "var(--primary)"
      - "bg-blue-500"
~~~

When using simple strings, the value is used as both the label and the swatch preview.

### Named Colors with Swatches

Define colors as hashes to control the label, stored value, and swatch preview independently:

~~~ yaml
- name: theme_color
  type: Color
  settings:
    colors:
      - name: Primary
        value: "var(--color-primary)"
        swatch: "#3b82f6"
      - name: Secondary
        value: "var(--color-secondary)"
        swatch: "#8b5cf6"
      - name: Danger
        value: danger
        swatch: "#ef4444"
~~~

The `swatch` controls the color shown in the select dropdown. This is useful when the stored value is not a visual color (like a CSS custom property or class name). If `swatch` is omitted, it defaults to the `value`.

### Custom Color

When using predefined colors, you can allow a free color picker alongside the palette:

~~~ yaml
- name: accent_color
  type: Color
  settings:
    colors:
      - name: Primary
        value: "var(--color-primary)"
        swatch: "#3b82f6"
    custom_color: true
~~~

This adds a "Custom color" option to the select that opens a free color picker for arbitrary values.

## File

Stores a reference to a file attachment from the Alchemy library.

The view renders a download link (`<a>` tag) to the attachment.

### Example

~~~ yaml
- name: download
  type: File
  settings:
    only: ['pdf', 'zip']
~~~

### Settings

#### link_text
`String`

Default text for the download link. Falls back to the attachment name.

#### css_classes
`Array<String>`

CSS classes available for the editor to choose from.

#### except
`Array<String>`

Exclude attachments with these file extensions from the selection.

#### only
`Array<String>`

Only show attachments with these file extensions in the selection.

## Audio

Stores a reference to an audio attachment from the Alchemy library.

The view renders an HTML `<audio>` element with a `<source>` child.

### Example

~~~ yaml
- name: podcast_player
  type: Audio
  settings:
    controls: true
~~~

### Settings

#### controls
`Boolean` (Default: `false`)

Show playback controls.

#### autoplay
`Boolean` (Default: `false`)

Start playing automatically.

#### muted
`Boolean` (Default: `false`)

Start muted.

#### loop
`Boolean` (Default: `false`)

Loop playback.

#### except
`Array<String>`

Exclude attachments with these file extensions from the selection.

#### only
`Array<String>`

Only show attachments with these file extensions in the selection.

## Video

Stores a reference to a video attachment from the Alchemy library.

The view renders an HTML `<video>` element with a `<source>` child.

### Example

~~~ yaml
- name: background_video
  type: Video
  settings:
    autoplay: true
    muted: true
    loop: true
    playsinline: true
~~~

### Settings

#### controls
`Boolean` (Default: `false`)

Show playback controls.

#### autoplay
`Boolean` (Default: `false`)

Start playing automatically.

#### muted
`Boolean` (Default: `false`)

Start muted.

#### loop
`Boolean` (Default: `false`)

Loop playback.

#### playsinline
`Boolean` (Default: `false`)

Play inline on mobile devices instead of fullscreen.

#### preload
`String`

The preload strategy. Accepts `none`, `metadata`, or `auto`.

#### width
`String`

The width of the video element.

#### height
`String`

The height of the video element.

#### except
`Array<String>`

Exclude attachments with these file extensions from the selection.

#### only
`Array<String>`

Only show attachments with these file extensions in the selection.

## Datetime

Stores a date and time value. The editor renders a datepicker.

The view output is passed through Rails' I18n library, so it is fully localizable.

### Settings

#### date_format
`String|Symbol`

Either a `String` with the format of [Ruby's `strftime`](https://ruby-doc.org/stdlib-2.6.1/libdoc/date/rdoc/Date.html#method-i-strftime) or a `Symbol` of a [date/time format](https://guides.rubyonrails.org/i18n.html#adding-date-time-formats) defined in your locale files.

## Page

References an [Alchemy page](pages). The editor renders a page select box.

Useful for follow-up pages, related content links, or any case where you need to reference another page.

### Example

~~~ yaml
- name: contact_form
  ingredients:
    - role: follow_up_page
      type: Page
~~~

### Settings

#### query_params
`Hash`

Additional query parameters appended to the page URL.

## Node

References an Alchemy menu node. The editor renders a node select box.

Useful for linking to specific menu entries or navigation items.

### Example

~~~ yaml
- name: call_to_action
  ingredients:
    - role: menu_link
      type: Node
~~~

### Settings

#### query_params
`Hash`

Additional query parameters appended to the node URL.

## Boolean

Stores a boolean value. The editor renders a checkbox.

## Html

Stores raw HTML code, useful for embeds or tracking snippets.

::: warning
The view renders the raw, unsanitized output. Be careful with user-provided content.
:::
