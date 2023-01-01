# How To: Create a blog template

A blog is an appropriate way to present information about formal and informal events or extraordinary experiences.

In this guide you will learn how to:

-   Define blog layout and elements
-   Integration in your existing application

## Conceptual page and content structuring

Imagine you like to have a simple blog template on your website. First of all as mentioned in [about AlchemyCMS](about) you should identify required components in your blog layout. Common components are a **headline**, a **blog post** itself and **sidebar blocks** for category overview and featured posts.

Following the steps you will create blog template according to [Foundation Zurb](http://foundation.zurb.com/). (© ZURB, Inc)

*We will build this template using the [Blog sample](http://foundation.zurb.com/page-templates/blog.html)*

## Concept and structure

Visit the Blog sample page and have a deep look at the layout.

Let us start to divide the template. We can identify the following page elements:

-   **blog post (multiple)** contains title, date, author, image and text
-   **categories block** contains list of categories
-   **featured block** contains text block with link to favorite blog post

## Prerequisites

At the beginning some preparation is required.
First of all, follow these instruction provided by Zurb to [Add Foundation to your Rails app](http://foundation.zurb.com/docs/applications.html).

Hence the necessary preparations are completed.

## Define elements

First of all we define the elements we need in `config/alchemy/elements.yml`. The individual page elements (see [Concept and structure](#concept-and-structure)) could be considered as an element.

### Blog title

The blog should have a unique title. The title element contains a `title` and a `text` which represents a description or motto. In both cases we choose an `Text`, due to the fact that the `title` and the `text` will contain simple text.

The `default` attribute provides the preset value, if the user didn't specify a motto or description (in Alchemy's backend).

~~~ yaml
- name: blog_title
  unique: true
  ingredients:
    - role: title
      type: Text
      default: Blog
    - role: text
      type: Text
      default: This is my blog. It's awesome.
~~~

### Blog post

A `blog_post` element has a title, date, author, image and text.

The title is represented by `blog_post_title`. It's just a text, so we took `Text` as type. Below `settings` we use `linkable: true`, because the user should be able to choose a link for the title of the blog post.

The meta data like author and creation date corresponds to `blog_post_meta`.

The `blog_post_intro_text` text as well as the main content `blog_post_content` get the type `Richtext`, since the user likes to add multiline paragraphs.

The `blog_post_image` is of type `Picture`. This will empower the user to add an image.

~~~ yaml
- name: blog_post
  ingredients:
    - role: blog_post_title
      type: Text
      default: Blog Post Title
      settings:
        linkable: true
    - role: blog_post_meta
      type: Text
      default: "Written by John Smith on August 12, 2012"
    - role: blog_post_intro_text
      type: Richtext
    - role: blog_post_image
      type: Picture
    - role: blog_post_content
      type: Richtext
~~~

### Categories Block

The 'categories block' has a headline and a list of available categories.

The `categories_headline` is represented by an `Text`. In the backend the user should be able to add categories easily and dynamically. That's the reason why we chose the `nestable_elements` feature.

~~~ yaml
- name: categories_block
  ingredients:
    - role: categories_headline
      type: Text
      default: Categories
      nestable_elements:
        - category

- name: category
  ingredients:
    - role: name
      type: Text
      settings:
        linkable: true
~~~

### Featured block

The 'featured block' with a headline, text and a link.

~~~ yaml
- name: featured
  unique: true
  ingredients:
    - role: featured_headline
      type: Text
      default: "Featured"
    - role: featured_text
      type: Richtext
    - role: featured_link
      type: Text
      settings:
        linkable: true
~~~

::: tip
Instead of `Text` you could alternatively use `Link` for 'featured_link'.
:::

## Define blog page layout

After the definition of the elements, you we will continue with the defintion of an appropriate page layout. Page layout are specified in `config/alchemy/page_layouts.yml`.

Add a new page layout for your blog template:

~~~ yaml
- name: blog
  elements:
    - blog_title
    - blog_post
    - categories_block
    - featured
  autogenerate:
    - blog_title
~~~

The `autogenerate` attribute allows to define elements which will be generated automatically, when the user creates a new page in backend.

## Generate and customize the partials

The command

~~~ bash
rails g alchemy:elements --skip
~~~

creates the partials according to the element definition in the `elements.yml`.

The partials are stored in `app/views/alchemy/elements/`.

e.g. the partial for 'blog_post' element: `_blog_post.html.erb`

### Customize the partials

In order to adapt the output of the elements you have to change the partial. The command above generates default partials. The `_blog_post.html.erb` might look like this:

~~~ erb
<% cache(blog_post) do %>
  <%= element_view_for(blog_post) do |el| %>
    <div class="blog_post_title">
      <%= el.render :blog_post_title %>
    </div>
    <div class="blog_post_meta">
      <%= el.render :blog_post_meta %>
    </div>
    <div class="blog_post_intro_text">
      <%= el.render :blog_post_intro_text %>
    </div>
    <div class="blog_post_image">
      <%= el.render :blog_post_image %>
    </div>
    <div class="blog_post_content">
      <%= el.render :blog_post_content %>
    </div>
  <% end %>
<% end %>
~~~

#### `_blog_post_.html.erb`

The blog post should match with the layout of the blog page in general, therefore we edit the partial:

~~~ erb
<% cache(blog_post) do %>
  <%= element_view_for(blog_post) do |el| %>
    <article>
      <h3><%= el.render :blog_post_title %></h3>
      <h6><%= el.render :blog_post_meta %></h6>
      <div class="row">
        <div class="large-6 columns">
          <%= el.render :blog_post_intro_text %>
        </div>
        <div class="large-6 columns">
          <%= el.render :blog_post_image %>
        </div>
      </div>
      <%= el.render :blog_post_content %>
    </article>
    <hr/>
  <% end %>
<% end %>
~~~

For the remaining elements replace the content of the correspondig partials with the following code snippets:

#### `_blog_title.html.erb`

~~~ erb
<% cache(blog_title) do %>
  <%= element_view_for(blog_title, tag: 'h1') do |el| %>
    <%= el.render :title %>
    <small><%= el.render :text %></small>
  <% end %>
<% end %>
~~~

#### `_categories_block.html.erb`

~~~ erb
<% cache(categories_block) do %>
  <%= element_view_for(categories_block) do |el| %>
    <h5><%= el.render :categories_headline %></h5>
    <%= render categories_block.nested_elements %>
  <% end %>
<% end %>
~~~

#### `_category.html.erb`

~~~ erb
<% cache(category) do %>
  <%= element_view_for(category, tag: 'p') do |el| %>
    <%= el.render :name %>
  <% end %>
<% end %>
~~~

#### `_featured.html.erb`

~~~ erb
<% cache(featured) do %>
  <%= element_view_for(featured) do |el| %>
    <h5><%= el.render :featured_headline %></h5>
    <%= el.render :featured_text %>
    <p><%= el.render :featured_link %></p>
  <% end %>
<% end %>
~~~

## Embed the elements into your page layout

Finally you have to integrate your elements into the page layout.

### Create new page layout view

Create a new file called `_blog.html.erb` in `app/views/alchemy/page_layouts` and copy the plain html code from [Foundation Zurb Blog Template Raw](https://gist.githubusercontent.com/ghaida/5054379/raw/f080e139a4e25c4548b265e7229cd6dbe09bff92/gistfile1.html).

### Edit blog page layout view

In `app/views/alchemy/page_layouts/_blog.html` search for
(inside 'Nav Bar' comment)

~~~ erb
<h1>
  Blog <small>This is my blog. It's awesome.</small>
</h1>
~~~

and replace with:

~~~ erb
<%= render_elements only: 'blog_title' %>
~~~

The **blog_title** set in the backend is now visible in the blog page layout context.

Inside the commented 'Main Blog Content' replace the whole content of `<div class="large-9 columns" role="content">` with

~~~ erb
<%= render_elements only: 'blog_post' %>
~~~

to embed the **blog_post** elements into the page layout view.

Inside 'Sidebar' comment replace

~~~ erb
<h5>Categories</h5>

<ul class="side-nav">
  <li>
    <a href="#">News</a>
  </li>
  <li>
    <a href="#">Code</a>
  </li>
  <li>
    <a href="#">Design</a>
  </li>
  <li>
    <a href="#">Fun</a>
  </li>
  <li>
    <a href="#">Weasels</a>
  </li>
</ul>
~~~

with

~~~ erb
<%= render_elements only: 'categories_block' %>
~~~

and replace the content of `<div class="panel">` with

~~~ erb
<%= render_elements only: 'featured' %>
~~~

Now you can run

~~~ bash
rails server
~~~

to start the server.
