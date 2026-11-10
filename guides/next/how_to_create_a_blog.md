# How To: Create a Blog

This guide walks you through building a blog with Alchemy. Each blog post is a [page](pages) with its own URL, giving you a built-in publishing workflow, publication dates, and tagging support. The blog overview page automatically lists all published posts.

You will create two [page layouts](pages#defining-page-layouts) — one for the overview and one for individual posts — along with their elements and view partials.

## Define Elements

Define your blog elements in `config/alchemy/elements.yml`.

### Post Header

The post header captures all metadata in a single element — headline, author, hero image, and a teaser excerpt:

~~~ yaml
# config/alchemy/elements.yml
- name: post_header
  unique: true
  taggable: true
  ingredients:
    - role: headline
      type: Headline
      settings:
        levels: [1]
    - role: author
      type: Text
    - role: image
      type: Picture
      settings:
        size: 1200x600
        crop: true
    - role: teaser
      type: Richtext
~~~

::: tip
The post's title, URL, and publication date come from the page. The `teaser` is used as a short excerpt on the overview page. With `taggable: true`, editors can [tag](elements#tagging) posts with categories.
:::

### Post Text

A repeatable text section with a headline. The `anchor: from_value` setting auto-generates an `id` attribute from the headline text, enabling deep links to sections within a post:

~~~ yaml
- name: post_text
  ingredients:
    - role: headline
      type: Headline
      settings:
        levels: [2, 3]
        anchor: from_value
    - role: text
      type: Richtext
~~~

### Post Picture

A repeatable image element with responsive `srcset` support:

~~~ yaml
- name: post_picture
  ingredients:
    - role: image
      type: Picture
      settings:
        srcset: ["400x", "800x", "1200x"]
        sizes: ["(max-width: 600px) 400px", "(max-width: 900px) 800px", "1200px"]
~~~

### Blog Overview

The overview element with an editable headline. Its partial queries and renders the blog posts automatically:

~~~ yaml
- name: blog_overview
  unique: true
  ingredients:
    - role: headline
      type: Headline
      settings:
        levels: [1]
      default: Blog
~~~

## Define Page Layouts

~~~ yaml
# config/alchemy/page_layouts.yml
- name: blog
  unique: true
  cache: false # overview lists child pages, must reflect publish changes
  elements:
    - blog_overview
  autogenerate:
    - blog_overview

- name: blogpost
  elements:
    - post_header
    - post_text
    - post_picture
  autogenerate:
    - post_header
~~~

::: tip
Editors create new blog posts by adding child pages under the blog overview page and selecting the `blogpost` layout.
:::

## Customize Views

Generate the view partials for your elements and page layouts:

~~~ bash
bin/rails g alchemy:elements --skip
bin/rails g alchemy:page_layouts --skip
~~~

The generated page layout partials render all elements with `<%= render_elements %>`. For the blog post, wrap it in an `<article>` tag in `app/views/alchemy/page_layouts/_blogpost.html.erb`:

~~~ erb
<article class="blog-post">
  <%= render_elements %>
</article>
~~~

Then customize the element partials in `app/views/alchemy/elements/`:

### `_post_header.html.erb`

~~~ erb
<%= element_view_for(post_header, tag: "header") do |el| %>
  <%= el.render :headline %>
  <p class="meta">
    By <%= el.render :author %> &middot;
    <time><%= l(page.public_on, format: :long) %></time>
  </p>
  <%= el.render :teaser %>
  <%= el.render :image %>
<% end %>
~~~

### `_post_text.html.erb`

~~~ erb
<%= element_view_for(post_text) do |el| %>
  <%= el.render :headline %>
  <%= el.render :text %>
<% end %>
~~~

### `_post_picture.html.erb`

~~~ erb
<%= element_view_for(post_picture) do |el| %>
  <%= el.render :image %>
<% end %>
~~~

### `_blog_overview.html.erb`

The overview element lists all published child pages:

~~~ erb
<%= element_view_for(blog_overview) do |el| %>
  <%= el.render :headline %>
  <% posts = blog_overview.page.children.published.order(public_on: :desc) %>
  <%= render partial: "post_preview", collection: posts, as: :post %>
<% end %>
~~~

### `_post_preview.html.erb`

~~~ erb
<% cache(post) do %>
  <% header = post.elements.find_by(name: "post_header") %>
  <% return unless header %>
  <article class="post-preview">
    <% if header.ingredient_by_role(:image)&.picture %>
      <%= render header.ingredient_by_role(:image), size: "600x300", crop: true %>
    <% end %>
    <h2><%= link_to post.title, show_alchemy_page_path(post) %></h2>
    <time><%= l(post.public_on, format: :long) %></time>
    <p><%= header.ingredient_by_role(:teaser)&.value&.truncate(200) %></p>
  </article>
<% end %>
~~~

