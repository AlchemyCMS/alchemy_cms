# Customizing the Richtext Editor

This guide explains how to override the default settings of the TinyMCE richtext editor and customize it.
After reading this guide you will be able to:

* Overriding default settings
* Customizing the toolbar
* Changing the default stylesheet

## Override the default settings

To override the default settings you have to create a `tinymce.rb` initializer file into `config/initializers`.

Alchemys default settings for TinyMCE can be found in the [documentation](https://www.rubydoc.info/github/AlchemyCMS/alchemy_cms/Alchemy/Tinymce)

### A Minimal Editor

Let's reduce the options for formatting the text to a minimum.

Because Alchemy merges the default options and your custom options you just need to pass the options you want to override to `Alchemy::Tinymce.init`.

~~~ ruby
# config/initializers/tinymce.rb
Alchemy::Tinymce.init = {
  toolbar: [
    'bold italic underline',
    'pastetext charmap code | undo redo | alchemy_link unlink | alignleft aligncenter alignright alignjustify'
  ]
}
~~~

Now only this three basic formatting options are available in the first toolbar to your editors.
In the second toolbar are now the align formatting options available.

::: warning NOTE
Overriding options always in the initializer applies to all richtext editors in all elements in Alchemy.
:::

## Custom toolbar buttons

You can customize the TinyMCE toolbar with a lot of buttons. Find them in the [TinyMCE documentation](http://www.tinymce.com/wiki.php/Controls)

### Adding a format select box

Let's add a format select to our editors so they can insert headlines into their texts.

In the TinyMCE documentation we found our configuration option:

~~~ js
tinymce.init({
  ...
  block_formats: "Paragraph=p;Header 1=h1;Header 2=h2;Header 3=h3"
});
~~~

We just have to _convert_ this javacript object into a ruby hash.
And we need to insert the format select into the set of buttons.

~~~ ruby
# config/initializers/tinymce.rb
Alchemy::Tinymce.init = {
  toolbar: [
    'bold italic underline | strikethrough subscript superscript | numlist bullist indent outdent | removeformat | fullscreen',
    'pastetext | formatselect | charmap code | undo redo | alchemy_link unlink'
  ],
  block_formats: "Header 2=h2;Paragraph=p"
}
~~~

That's it. Now the editor can format a block of text as headline 2. Nice!

::: warning NOTE
Custom buttons always appear in all richtext editors in all elements in Alchemy.
:::

## Adding editor plugins
It is possible to extend the tinymce editor with plugins.
All you have to do is to download the tinymce plugin and copy the folder to
`vendor/assets/javascripts/tinymce/plugins`

and add the following content to `config/initializers/tinymce.rb`

~~~ ruby
Alchemy::Tinymce.init = {
  plugins: Alchemy::Tinymce.plugins + ['colorpicker'],
  toolbar: [
    'bold italic underline | strikethrough subscript superscript | numlist bullist indent outdent | removeformat | alignleft aligncenter alignright | fullscreen', 
    'pastetext charmap hr | undo redo | alchemy_link unlink anchor | code | colorpicker'
  ]
}
~~~

Another example configuration could be:

~~~ ruby
Alchemy::Tinymce.plugins += ['textcolor']
Alchemy::Tinymce.init = {
  toolbar: [
    'bold italic underline | strikethrough subscript superscript | numlist bullist indent outdent | removeformat | fullscreen',
    'pastetext | charmap code | undo redo | alchemy_link unlink | help | forecolor backcolor'
  ],
}
~~~

This example adds the textcolor plugin and adds its button to the toolbar.


## Setting a custom stylesheet

It is a good practice to set the stylesheet TinyMCE uses to display text in the editor area to the one you use to render the website.

::: tip INFO
Please read more on custom stylesheets in the [TinyMCE documentation](http://www.tinymce.com/wiki.php/Configuration:content_css)
:::

### Create the css file

Put a `tinymce_content.css` stylesheet into your `app/assets/stylesheets` folder.

### Setting the stylesheet

~~~ ruby
# config/initializers/tinymce.rb
Alchemy::Tinymce.init = {
  content_css: "/assets/tinymce_content.css"
}
~~~

### Compile the asset for production

In production mode (on your server) Rails uses compiled assets to speed up the rendering of your page.
As default Rails only compiles the `application.css` stylesheet. But you can tell Rails to compile our custom TinyMCE stylesheet as well.

Open the `config/environments/production.rb` file in your editor and insert this line:

~~~ ruby
config.assets.precompile += %w( tinymce_content.css )
~~~

## Per element customization

You can also set TinyMCE configuration options per element.

~~~ yaml
# elements.yml
- name: minimal_text
  contents:
  - name: text
    type: EssenceRichtext
    settings:
      tinymce:
        toolbar:
        - 'bold italic underline',
        - 'pastetext charmap code | undo redo | alchemy_link unlink | alignleft aligncenter alignright alignjustify'
~~~

## Configuration Syntax

You can set any [TinyMCE configuration option](http://www.tinymce.com/wiki.php/Configuration). Just remember to _convert_ the javascript syntax into ruby.

### Convertions Tips

Javascript and Ruby has very similiar syntax. Especially if you use the new Ruby 1.9 Hash syntax. So converting is no big deal.

#### Object to Hash

~~~ js
{ "key" : "value" } => { key: "value" }
~~~

#### Array to Array

Arrays have the same syntax. So you can just take them as they are.

~~~ js
["1", "2", "3", "4"] => ["1", "2", "3", "4"]
~~~

#### Object with Array as value

~~~ js
{ "key" : ["value1", "value2"] } => { key: ["value1", "value2"] }
~~~

#### Object with Object as value

~~~ js
{ "key" : { "value" : ["value1", "value2"] } } => { key: { value: ["value1", "value2"] } }
~~~
