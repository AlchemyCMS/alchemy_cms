# Best Practice: Create a blog template

A blog is an appropriate way to present information about formal and informal events or extraordinary experiences.

In this guide you will learn how to:

-   Define blog layout and elements
-   Integration in your existing application

## Conceptual page and content structuring

Imagine you like to have a simple blog template on your website. First of all as mentioned in [about AlchemyCMS](about.html) you should identify required components in your blog layout. Common components are a **headline**, a **blog post** itself and **sidebar blocks** for category overview and featured posts.

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

The blog should have a unique title. The title element contains a `title` and a `text` which represents a description or motto. In both cases we choose an `EssenceText`, due to the fact that the `title` and the `text` will contain simple text.

The `default` attribute provides the preset value, if the user didn't specify a motto or description (in Alchemy's backend).

~~~ yaml
- name: blog_title
  unique: true
  contents:
    - name: title
      type: EssenceText
      default: Blog
    - name: text
      type: EssenceText
      default: This is my blog. It's awesome.
~~~

### Blog post

A `blog_post` element has a title, date, author, image and text.

The title is represented by `blog_post_title`. It's just a text, so we took `EssenceText` as type. Below `settings` we use `linkable: true`, because the user should be able to choose a link for the title of the blog post.

The meta data like author and creation date corresponds to `blog_post_meta`.

The `blog_post_intro_text` text as well as the main content `blog_post_content` get the type `EssenceRichtext`, since the user likes to add multiline paragraphs.

The `blog_post_image` is of type `EssencePicture`. This will empower the user to add an image.

~~~ yaml
- name: blog_post
  contents:
    - name: blog_post_title
      type: EssenceText
      default: Blog Post Title
      settings:
        linkable: true
    - name: blog_post_meta
      type: EssenceText
      default: "Written by John Smith on August 12, 2012"
    - name: blog_post_intro_text
      type: EssenceRichtext
    - name: blog_post_image
      type: EssencePicture
    - name: blog_post_content
      type: EssenceRichtext
~~~

### Categories Block

The 'categories block' has a headline and a list of available categories.

The `categories_headline` is represented by an `EssenceText`. In the backend the user should be able to add categories easily and dynamically. That's the reason why we chose the `nestable_elements` feature.

~~~ yaml
- name: categories_block
  contents:
    - name: categories_headline
      type: EssenceText
      default: Categories
      nestable_elements:
        - category

- name: category
  contents:
    - name: name
      type: EssenceText
      settings:
        linkable: true
~~~

### Featured block

The 'featured block' with a headline, text and a link.

~~~ yaml
- name: featured
  unique: true
  contents:
    - name: featured_headline
      type: EssenceText
      default: "Featured"
    - name: featured_text
      type: EssenceRichtext
    - name: featured_link
      type: EssenceText
      settings:
        linkable: true
~~~

::: tip
Instead of `EssenceText` you could alternatively use `EssenceLink` for 'featured_link'.
:::

## Define blog page layout

After the definition of the elements, you we will continue with the defintion of an appropriate page layout. Page layout are specified in `config/alchemy/page_layouts.yml`.

Add a new page layout for your blog template:

~~~ yaml
- name: blog
  elements: [blog_title, blog_post, categories_block, featured]
  autogenerate: [blog_title]
~~~

The `autogenerate` attribute allows to define elements which will be generated automatically, when the user creates a new page in backend.

## Generate and customize the partials

The command

~~~ shell
rails g alchemy:elements --skip
~~~

creates the view and editor partial according to the element definition in the `elements.yml`.

The partials are stored in `app/views/alchemy/elements/`.

e.g. the view partial for 'blog_post'- element: `_blog_post_view.html.erb` and editor partial: `_blog_post_editor.html.erb`

### Customize the partials

In order to adapt the output of the elements you have to change the view partial. The command above generates default partials. The `_blog_post_view.html.erb` might look like this:

~~~ erb
<% cache(element) do %>
  <%= element_view_for(element) do |el| %>
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

The blog post should match with the layout of the blog page in general, therefore we edit the view partial:

~~~ erb
<% cache(element) do %>
  <%= element_view_for(element) do |el| %>
    <article>
      <h3>
        <%= el.render :blog_post_title %>
      </h3>
      <h6>
        <%= el.render :blog_post_meta %>
      </h6>
      <div class="row">
        <div class="large-6 columns">
          <p>
            <%= el.render :blog_post_intro_text %>
          </p>
        </div>
        <div class="large-6 columns">
          <%= el.render :blog_post_image %>
        </div>
      </div>
      <p>
        <%= el.render :blog_post_content %>
      </p>
    </article>
    <hr/>
  <% end %>
<% end %>
~~~

The editor partial is used for the backend, so we keep this file untouched. Feel feel to edit this partial if you like.

For the remaining elements replace the content of the correspondig view partials with the following code snippets:

**`_blog_title_view.html.erb`**

~~~ erb
<% cache(element) do %>
  <%= element_view_for(element, tag: 'h1') do |el| %>
    <%= el.render :title %>
    <small><%= el.render :text %></small>
  <% end %>
<% end %>
~~~

**`_categories_block_view.html.erb`**

~~~ erb
<% cache(element) do %>
  <%= element_view_for(element) do |el| %>
    <h5><%= el.render :categories_headline %></h5>
    <% element.nested_elements.each do |nested_element| %>
      <%= render_element(nested_element) %>
    <% end %>
  <% end %>
<% end %>
~~~

**`_category_view.html.erb`**

~~~ erb
<% cache(element) do %>
  <%= element_view_for(element, tag: 'p') do |el| %>
    <%= el.render :name %>
  <% end %>
<% end %>
~~~

**`_featured_view.html.erb`**

~~~ erb
<% cache(element) do %>
  <%= element_view_for(element) do |el| %>
    <h5>
      <%= el.render :featured_headline %>
    </h5>
    <p>
      <%= el.render :featured_text %>
    </p>
    <p>
      <%= el.render :featured_link %>
    </p>
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

~~~ shell
rails server
~~~

to start the server.
