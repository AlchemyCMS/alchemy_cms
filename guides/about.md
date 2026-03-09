---
prev: false
next:
  text: Getting Started
  link: getting_started
---

# About AlchemyCMS

Alchemy is a flexible, developer-friendly content management framework for Ruby on Rails. It gives you full control over markup and styling while providing editors with a powerful, intuitive admin interface.

## Rails engine

Alchemy is a [Rails engine](https://guides.rubyonrails.org/engines.html) that integrates into your existing application. It uses standard Rails conventions — ERB templates, ActiveRecord, asset pipeline — so there is nothing new to learn.

## Content architecture

Unlike CMS systems that store complete HTML pages, Alchemy stores only structured content: text, references to images and attachments, and richtext. No HTML markup, no CSS, no layout. You control how content is rendered.

### The content hierarchy

~~~
Site
  Language
    Page (nested set tree)
      PageVersion (draft and public)
        Element (can be nested)
          Ingredient (typed content fields)
~~~

- A **Site** has one or more **Languages**.
- Each language has a tree of **[Pages](pages)**.
- Each page maintains a **draft version** for editing and a **public version** for visitors. When a page is published, Alchemy duplicates the draft's elements into the public version. This is handled transparently.
- Pages contain **[Elements](elements)** — reusable content components like articles, hero sections, or cards. Elements can be nested.
- Elements contain **[Ingredients](ingredients)** — typed content fields like Text, Richtext, Picture, or Boolean.

### The render flow

Alchemy uses standard [Rails partials](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials) and [ViewComponents](https://viewcomponent.org). It has no custom templating language.

When Alchemy renders a page, these files are used:

1. `app/views/layouts/application.html.erb` — your application layout
2. `app/views/alchemy/page_layouts/_<page_layout>.html.erb` — the page layout partial
3. `app/views/alchemy/elements/_<element>.html.erb` — the element partial
4. Ingredient view components render the individual content fields

### Planning your content structure

Start by identifying the different types of pages your site needs (called page layouts). Every structurally different page should have its own layout. [More about pages.](pages)

Then split the content within each layout into elements. Group related content fields into reusable components. Elements are the key building blocks of Alchemy. [More about elements.](elements)

Finally, define the ingredients for each element — the individual content fields like headlines, images, and text. [More about ingredients.](ingredients)

## Image processing

Alchemy renders images on the fly using [ImageMagick](https://imagemagick.org) or [libvips](https://www.libvips.org). Images are stored as originals in the picture library. Editors assign them to elements and can crop them using the built-in cropping tool. You define the rendering dimensions and output format. [More about rendering images.](render_images)

## Caching

Alchemy uses Rails' Russian doll caching for fast content delivery. With every page request Alchemy sends `Cache-Control` headers that CDNs, proxies and browsers use to cache the page. Caching can be configured globally or per page layout. [More about caching.](configuration#caching)

## Admin modules

Alchemy comes with these admin modules:

- **[Pages](pages)** — manage the page tree and edit content
- **[Menus](menus)** — manage navigation trees independently from pages
- **Languages** — multi-language support
- **Sites** — multi-site support
- **Library** — picture and attachment management
- **Tags** — tagging for pictures, attachments, and pages
- **Users** — user management (with [alchemy-devise](https://github.com/AlchemyCMS/alchemy-devise))

You can extend the admin with your own modules. A module is a Rails engine that registers itself with Alchemy. Your controllers can inherit from `Alchemy::Admin::ResourcesController` to get standard CRUD views. [More about creating modules.](how_to_create_modules)
