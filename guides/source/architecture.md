Alchemy's Architecture
----------------------

Alchemy is the most user friendly and flexible Rails based CMS today. In
this guide you will learn about Alchemy's powerful features:

-   The flexible content storing architecture
-   The image processing magick
-   Caching
-   The resources controller

endprologue.

### Rails Engine

Since the Alchemy CMS project started, it is a Rails engine. Rails 3.1 brought the namespacing and mounting possibility of Rails engines.
Alchemy CMS is taking advantage of these features since v2.1. You can read more about the [engines in the Rails guides](http://edgeguides.rubyonrails.org/engines.html).

### The Core modules

Alchemy CMS comes with six core modules:

1.  [Pages](pages.html)
2.  Languages
3.  Sites
4.  Users
5.  Tags
6.  Library (Pictures & Attachments)

The core modules can be extended by own modules. A module should be a Rails engine that registers itself at Alchemy.
Read more about [creating own modules](create_modules.html).

### Storing architecture

Alchemy stores content. Period. Really, that's it.

Unlike many other CMS's that store a whole page body with complete html
markup from one of these fancy WYSIWYG editors out there, Alchemy only
stores unformatted text, ids of objects (like attachments and pictures)
and only somewhat richtext content in the database. No html markup, no
css, no styling, no layout. Just pure content.

The webdeveloper is in full control of the markup and styling. The
editor just manages the content.

Isn't that what CMS really should mean?

### The Rendering Process en Detail

Alchemy strongly uses the Rails partial rendering mechanism. It has no
own templating language and no *special files*.

When Alchemy renders a Page, these files will be rendered:

1.  <code>app/views/layouts/application.html.erb</code>
2.  <code>app/views/alchemy/page_layouts/_NAME_OF_PAGE_LAYOUT.html.erb</code>
3.  <code>app/views/alchemy/elements/_NAME_OF_ELEMENT_view.html.erb</code>

NOTE: Since Alchemy v2.4 you can use Slim and HAML views as well.

INFO: Alchemy comes with tons of useful helpers that render these
partials for you. For further information please [have a look into the
PagesHelper documentation](http://rdoc.info/github/AlchemyCMS/alchemy_cms/Alchemy/PagesHelper.html)

### Processing images

Alchemy uses RMagick (the Ruby ImageMagick library) and Dragonfly (a
powerful image processing gem) to render images.

Images are stored as master images in the picture library. The editor
just assigns these master images to elements you provide. You also set
the image rendering bounderies. The max width and heigth values, or even
the size an image should be cropped to. Alchemy even comes with a fancy
Javascript based image cropper tool, so that the editor can define the
mask to be used.

[Read more about how to use the powerful image processing tools](render_images.html).

### Caching

If not deactivated in the [configuration](configuration.html), Alchemy
uses Rails action\_caching for fast content delivering.
This will cache all [page layout](page_layouts.html) partials where
[cells](cells.html) and [elements](elements.html) are rendered on.

### Resources Controller

Since Alchemy v2.1 there is a resources controller available. When
developing own modules for Alchemy, your controller can inherit from
that resources controller (`Alchemy::Admin::ResourcesController`) and will get all the
rails-like CRUD methods.

The standard partials for the backend views are also getting rendered.
They can be overwritten in your app, just use the expected filenames and
variables.

Read more details about the resources controller in the [module development](create_modules.html) guide.
