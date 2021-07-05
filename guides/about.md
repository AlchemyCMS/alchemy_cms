---
prev: /getting_started.html
next: /pages.html
---

# About AlchemyCMS

Alchemy is a user friendly and flexible Rails based CMS. In
this guide you will learn about Alchemy's powerful features:

* The flexible content storing architecture
* The image processing magick
* Caching
* The resources controller

## Rails Engine

AlchemyCMS is a Ruby on Rails engine. Read about [engines in the Rails guides](https://guides.rubyonrails.org/engines.html).

## The Core modules

AlchemyCMS comes with six core modules:

1. [Pages](pages.html)
2. Languages
3. Sites
4. Users
5. Tags
6. Library (Pictures & Attachments)

The core modules can be extended by own modules. A module should be a Rails engine that registers itself at Alchemy. Read more about [creating own modules](create_modules.html).

## Storing architecture

Unlike many other CMS's that store a whole page body with complete HTML markup, Alchemy only stores unformatted text, ids of objects (like attachments and pictures) and only some  richtext content in the database. No HTML markup, no CSS, no styling, no layout. Just pure content.

You, the webdeveloper are in full control of the markup and styling. The editor just manages the content.

### The render flow

Alchemy uses [Rails' partials](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials). It has no own templating language and no *special files*.

When Alchemy renders a typically Page, these files get usually rendered:

1. `app/views/layouts/application.html.erb`
2. `app/views/alchemy/page_layouts/_<page_layout>.html.erb`
3. `app/views/alchemy/elements/_<element>_view.html.erb`
4. `app/views/alchemy/elements/_<essence>_view.html.erb`

::: tip
Alchemy comes with useful helpers that help render these partials. For further information please [have a look into the Alchemy::PagesHelper documentation](https://www.rubydoc.info/github/AlchemyCMS/alchemy_cms/Alchemy/PagesHelper.html)
:::

### Tips for page and content structure

When working with AlchemyCMS the very first thing you should do is identify the website´s layout different page types (called page layouts).

Every page which is structurally different to another, should have its own page layout. A page layout is a HTML template with specified properties. [More about pages and their layouts »](/pages.html#defining-page-layouts)

After that you should identify fixed areas on the layout and define cells for sidebars, heroes and other groups of content. Cells render on page layouts and are acting as fixed containers for element groups. [More about cells »](/cells.html)

In any case you should split the layout into elements. That means grouping small parts of the websites content into reusable containers. Elements are rendered on page layouts or in cells and are the key component of Alchemy. [More about elements »](/elements.html)

An essence is the smallest part of content in Alchemy and represents a headline, an image, paragraphs and other values of content. [More about essences »](/essences.html)

## Processing images

Alchemy uses [ImageMagick®](https://www.imagemagick.org) and [Dragonfly](http://markevans.github.io/dragonfly/) to render images on-the-fly.

Images are stored as master images in the picture library. The editor just assigns these images to elements you provide them. You also set the image rendering boundaries. The max width and heigth values, or even the size an image should be cropped to. Alchemy comes with a built-in image cropping tool, so that the editor can define the mask to be used.

[Read more about how to use the powerful image processing tools](render_images.html).

## Caching

If not deactivated in the [configuration](/configuration.html), Alchemy uses Rails "Russian Doll Caching" for fast content delivering. This will cache all [page layout](/pages.html) partials where [cells](/cells.html) and [elements](/elements.html) are rendered on.

With every page request Alchemy sends cache headers that are used by CDNs, proxies and your vistors browser to cache the page body.

## Rails admin for your custom models

Alchemy can also be your Rails admin for your own custom models and controllers. When developing own modules for Alchemy, your controller can inherit from that resources controller (`Alchemy::Admin::ResourcesController`) to get typical Rails CRUD methods.

The standard templates for the backend views are also rendered. They can be overwritten in your app, just use the expected filenames and variables.

Read more details about the resources controller in the [module development](/create_modules.html) guide.
