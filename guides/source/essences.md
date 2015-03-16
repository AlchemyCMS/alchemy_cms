Essences
--------

Essences store the actual content of your site.

Alchemy comes with a lot of predefined essences for the regular needs of
a website project.\
Combine them like a chemestry kit into [elements](elements.html).

Essences are normal Rails models, so it is pretty easy to [add your
own](create_essences.html).

endprologue.

### Hints, Default Values and Element Titles

When defining elements, you can assign hints and default values to every
essence like this:

<yaml>

1.  config/alchemy/elements.yml\
    - name: article\
     contents:\
     - name: headline\
     type: EssenceText\
     hint: “This is the headline.”\
     - name: copy\
     type: EssenceRichtext\
     default: “Lorem ipsum”\
     as\_element\_title: true\
    </yaml>

-   <strong>hint</strong> <code>String</code><br>\
     A hint for the user in the admin frontend that describes what the
    essence is used for. The hint is [translatable](#translations) if
    you provide an I18n translation key instead of a complete sentence.
    You may also set it to true to default to the I18n key
    <code>alchemy.content\_hints.your-content-name</code>.
-   <strong>default</strong> <code>String</code><br>\
     The default text to prefill newly created elements. You may also
    use a symbol to set it to the I18n key
    <code>alchemy.default\_content\_texts.your-symbol-name</code>
-   <strong>as\_element\_title</strong> <code>Boolean</code><br>\
     For the displayed element title, the first content essence is used.
    Use this setting to override this behaviour and show other content
    as element title.

### EssenceText

Stores a <code>String</code> (max. 255 Chars.).

Use this for a headline, or a product name. The editor is renderd as a
single lined input field. The view output will be sanitized and HTML
escaped. So it’s XSS save.

#### Settings

-   <code>linkable</code> <code>Boolean</code><br>\
     If set to <code>true</code>, the user can link that essence.

#### Example

<yaml>\
- name: button\
 type: EssenceText\
 settings:\
 linkable: true\
</yaml>

### EssenceRichtext

Used to store long text.

The editor is rendered as a textarea with embedded TinyMCE Editor.

#### Settings

You can customize the TinyMCE editor of a single element instance.

-   <code>tinymce</code>

#### Example

<yaml>\
- name: text\
 type: EssenceRichtext\
 settings:\
 tinymce:\
 style\_formats:\
 - title: ‘Subheadline’\
 block: ‘h3’\
</yaml>

NOTE: See the [TinyMCE customization guide](customize_tinymce.html) for
all available options

### EssencePicture

Used to store references to pictures the user assigned through the
library.

The editor is rendered as a picture editor with a lot of options (i.e.
image cropper).

The view renders the assigned picture, resizes it, crops it and caches
the result.

INFO: See the [rendering images](render_images.html) guide for further
information on the powerful image rendering engine of Alchemy.

### EssenceDate

Use this to store a <code>DateTime</code> value. Renders a datepicker in
the editor partial.

The view output is passed through Rails’ I18n Library, so it is fully
localizable.

### EssenceHtml

Useful to store HTML code (i.e. a embed, or tracking code).

The view renders the raw, not sanitized or escaped output.

<strong>So be careful!</strong>

### EssenceBoolean

Stores a Boolean value in the database. Renders a checkbox in the editor
partial.

### EssenceSelect

Renders a select box in the editor partial and stores the value as
<code>String</code>.

Useful for letting your user select from a limited set of choices.

NOTE: Pretty handy together with the <code>page\_selector</code>
[helper](http://rubydoc.info/github/magiclabs/alchemy_cms/Alchemy/Admin/EssencesHelper#page_selector-instance_method).

#### Example

<ruby>

1.  app/views/alchemy/elements/\_my\_element\_editor.html.erb\
    …\
     el.render :width, :select\_values =\> [“200”, “300”, “400”]\
    …\
    </ruby>

### EssenceLink

Stores a url in the database. Useful for linking things, where the user
should not set the linked value itself. (Like in the EssenceText with
<code>linkable: true</code> option)

INFO: It is easy to add your own essence types to Alchemy.\
Read more about it in [this guide](create_essences.html)

### Configure essences

To configure the settings of an essence you have to pass it into its
settings in the <code>elements.yml</code>

#### Example

<yaml>\
- name: my\_element\
 contents:\
 - name: headline\
 type: EssenceText\
 settings:\
 - linkable: true\
</yaml>

 
