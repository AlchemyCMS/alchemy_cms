# Customizing the Richtext Editor

Alchemy uses [TinyMCE](https://www.tiny.cloud) as the richtext editor for [Richtext ingredients](ingredients#richtext). You can customize the toolbar, add plugins, apply custom stylesheets, and configure each editor instance independently.

## Default Configuration

Alchemy ships with a sensible default configuration:

~~~ ruby
{
  skin: "alchemy",
  width: "auto",
  resize: true,
  min_height: 250,
  menubar: false,
  statusbar: true,
  toolbar: [
    "bold italic underline | strikethrough subscript superscript | numlist bullist indent outdent | removeformat | fullscreen",
    "pastetext charmap hr | undo redo | alchemy_link unlink anchor | code"
  ],
  fix_list_elements: true,
  convert_urls: false,
  entity_encoding: "raw",
  paste_as_text: true
}
~~~

::: info NOTE
Default plugins: `alchemy_link`, `anchor`, `charmap`, `code`, `directionality`, `fullscreen`, `link`, `lists`.
:::

## Global Customization

To change TinyMCE settings for all richtext editors in your application, set `Alchemy::Tinymce.init` in an initializer. Your settings are **merged** with the defaults, so you only need to specify what you want to override.

~~~ ruby
# config/initializers/alchemy.rb
Alchemy::Tinymce.init = {
  toolbar: [
    "bold italic underline | numlist bullist | removeformat | fullscreen",
    "pastetext | undo redo | alchemy_link unlink | code"
  ]
}
~~~

::: info NOTE
Global settings apply to all richtext editors in all elements. Use [per-ingredient settings](#per-ingredient-customization) to customize individual editors.
:::

## Per-Ingredient Customization

You can override TinyMCE settings for individual Richtext ingredients in `config/alchemy/elements.yml` using the `tinymce` setting:

~~~ yaml
# config/alchemy/elements.yml
- name: article
  ingredients:
    - role: text
      type: Richtext
      settings:
        tinymce:
          toolbar:
            - "bold italic underline | removeformat"
            - "pastetext | undo redo | alchemy_link unlink | code"
~~~

Per-ingredient settings are merged with the global configuration, so you only need to specify the options you want to change for that specific editor.

### Adding Style Formats

Give editors a dropdown to apply predefined styles:

~~~ yaml
- name: text
  type: Richtext
  settings:
    tinymce:
      toolbar:
        - "bold italic underline | styleselect | removeformat | fullscreen"
        - "pastetext | undo redo | alchemy_link unlink | code"
      style_formats:
        - title: "Subheadline"
          block: "h3"
        - title: "Quote"
          block: "blockquote"
        - title: "Small"
          inline: "small"
~~~

::: tip
Keep your style formats minimal. Alchemy's strength is structured content with separate elements for different content types. Resist the temptation to turn a single richtext field into a full page editor.
:::

## Toolbar Buttons

The toolbar is defined as an array of strings. Each string is one toolbar row. Buttons are separated by spaces, groups are separated by `|`.

Common buttons:

| Button | Description |
|--------|-------------|
| `bold` `italic` `underline` `strikethrough` | Text formatting |
| `subscript` `superscript` | Sub/superscript |
| `numlist` `bullist` | Ordered and unordered lists |
| `indent` `outdent` | Indentation |
| `removeformat` | Clear formatting |
| `pastetext` | Paste as plain text |
| `alchemy_link` `unlink` | Alchemy's link dialog |
| `anchor` | Insert anchor |
| `charmap` | Special characters |
| `code` | View/edit HTML source |
| `fullscreen` | Toggle fullscreen editing |
| `hr` | Horizontal rule |
| `formatselect` | Block format dropdown |
| `styleselect` | Style format dropdown |

::: tip
See the [TinyMCE toolbar documentation](https://www.tiny.cloud/docs/tinymce/latest/available-toolbar-buttons/) for all available buttons.
:::

## Adding Plugins

TinyMCE can be extended with [community and premium plugins](https://www.tiny.cloud/docs/tinymce/latest/plugins/). Download the plugin and place it in `vendor/assets/javascripts/tinymce/plugins/` inside your app.

Then append it to `Alchemy::Tinymce.plugins` and add its buttons to the toolbar:

~~~ ruby
# config/initializers/alchemy.rb
Alchemy::Tinymce.plugins += ["table"]
Alchemy::Tinymce.init = {
  toolbar: [
    "bold italic underline | numlist bullist | removeformat | fullscreen",
    "pastetext | undo redo | alchemy_link unlink | table | code"
  ]
}
~~~

::: info NOTE
Plugins added to `Alchemy::Tinymce.plugins` beyond the built-in set are automatically preloaded in the admin interface.
:::

## Custom Stylesheet

You can apply a stylesheet to the TinyMCE editor area so the editing experience matches your site's typography:

~~~ ruby
# config/initializers/alchemy.rb
Alchemy::Tinymce.init = {
  content_css: "/assets/tinymce_content.css"
}
~~~

Create the stylesheet at `app/assets/stylesheets/tinymce_content.css`. This file is loaded inside the editor's iframe and controls how text appears while editing.

::: info NOTE
Alchemy automatically switches between a light (`alchemy`) and dark (`alchemy-dark`) editor skin based on the user's OS preference. Setting a custom `content_css` overrides the built-in dark mode content stylesheet, so make sure your stylesheet works in both modes if your editors use dark mode.
:::

## HTML Sanitization

Alchemy sanitizes richtext content before saving using Rails' [SafeListSanitizer](https://api.rubyonrails.org/classes/Rails/HTML/SafeListSanitizer.html). By default, Rails allows a generous set of tags (`p`, `strong`, `em`, `a`, `ul`, `ol`, `li`, `h1`-`h6`, `blockquote`, `br`, `img`, `span`, and more).

To be more restrictive, configure which tags and attributes are allowed per ingredient:

~~~ yaml
- name: text
  type: Richtext
  settings:
    sanitizer:
      tags:
        - p
        - strong
        - em
        - a
        - ul
        - ol
        - li
        - h2
        - h3
      attributes:
        - href
        - target
        - class
~~~
## Configuration Syntax

Any [TinyMCE configuration option](https://www.tiny.cloud/docs/tinymce/latest/editor-important-options/) can be used. When setting options in Ruby (initializer), convert JavaScript syntax to Ruby hashes:

~~~ js
// JavaScript
{
  block_formats: "Paragraph=p;Header 2=h2;Header 3=h3"
}
~~~

~~~ ruby
# Ruby
{
  block_formats: "Paragraph=p;Header 2=h2;Header 3=h3"
}
~~~

When setting options in YAML (elements.yml), use standard YAML syntax:

~~~ yaml
settings:
  tinymce:
    block_formats: "Paragraph=p;Header 2=h2;Header 3=h3"
    style_formats:
      - title: "Highlight"
        inline: "span"
        classes: "highlight"
~~~

::: tip
Use YAML anchors to share TinyMCE configurations across multiple elements:

~~~ yaml
# config/alchemy/elements.yml
- name: article
  ingredients:
    - role: text
      type: Richtext
      settings:
        tinymce: &minimal_tinymce
          toolbar:
            - "bold italic underline | alchemy_link unlink | code"

- name: news
  ingredients:
    - role: body
      type: Richtext
      settings:
        tinymce: *minimal_tinymce
~~~
:::
