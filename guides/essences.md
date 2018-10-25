# Essences

Essences store the actual content of your site.

Alchemy comes with a lot of predefined essences for the regular needs of a website project.
Combine them like a chemestry kit into "elements":elements.html.

Essences are normal Rails models, so it is pretty easy to "add your own":create_essences.html.

## Definition

When defining elements, you can assign hints and default values to every essence like this:

~~~ yaml
# config/alchemy/elements.yml
- name: article
  contents:
    - name: headline
      type: EssenceText
      hint: "This is the headline."
    - name: copy
      type: EssenceRichtext
      default: "Lorem ipsum"
      as_element_title: true
~~~

* **hint** `String`

  A hint for the user in the admin frontend that describes what the essence is used for. The hint is "translatable":#translations if you provide an I18n translation key instead of a complete sentence. You may also set it to true to default to the I18n key `alchemy.content_hints.your-content-name`.

* **default** `String`

  The default text to prefill newly created elements. You may also use a symbol to set it to the I18n key `alchemy.default_content_texts.your-symbol-name`

* **as_element_title** `Boolean`

  For the displayed element title, the first content essence is used. Use this setting to override this behaviour and show other content as element title.

## EssenceText

Stores plain text of 255 chars max.

Use this for a headline, or a product name. The editor is renderd as a single lined input field. The view output will be sanitized and HTML escaped. So it's XSS save.

### Settings


* **linkable** `Boolean`

  If set to `true`, the user can add a link to the text.

### Example

~~~ yaml
- name: button
  type: EssenceText
  settings:
    linkable: true
~~~

## EssenceRichtext

Used to store paragraphs of formatted text.

The editor is rendered as a textarea with embedded TinyMCE Editor.

### Settings

You can customize the TinyMCE editor of a single element instance.

* **tinymce** `Hash`

### Example

~~~ yaml
- name: text
  type: EssenceRichtext
  settings:
    tinymce:
      style_formats:
        - title: 'Subheadline'
          block: 'h3'
~~~

::: tip
See the [TinyMCE customization guide](customize_tinymce.html) for all available options
:::

## EssencePicture

Used to store references to pictures the user assigned through the library.

The editor is rendered as a picture editor with a lot of options (i.e. image cropper).

The view renders the assigned picture, resizes it, crops it and caches the result.

::: tip
See the [rendering images](render_images.html) guide for further information on the powerful image rendering engine of Alchemy.
:::

## EssenceDate

Use this to store a `DateTime` value. Renders a datepicker in the editor partial.

The view output is passed through Rails' I18n Library, so it is fully localizable.

## EssenceHtml

Useful to store HTML code (i.e. a embed, or tracking code).

::: warning
The view renders the raw, not sanitized or escaped output.
**So be careful!**
:::

## EssenceBoolean

Stores a `Boolean` value in the database. Renders a checkbox in the editor partial.

## EssenceSelect

Renders a select box in the editor partial and stores the value as `String`.

Useful for letting your user select from a limited set of choices.

* **select_values** `Array`

### Example

~~~ yaml
- name: width
  type: EssenceSelect
  settings:
    select_values: ['200', '300', '400']
~~~

## EssenceLink

Stores a url in the database. Useful for linking things, where the user should not set the linked value itself. (Like in the EssenceText with `linkable: true` option)

## Configure essences

To configure the settings of an essence you have to pass it into its settings in the `elements.yml`

### Example

~~~ yaml
- name: my_element
  contents:
    - name: headline
      type: EssenceText
      settings:
        linkable: true
~~~
