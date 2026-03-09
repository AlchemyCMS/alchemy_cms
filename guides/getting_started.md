---
prev: false
next:
  text: Elements
  link: elements
---

# Getting Started

This guide walks you through installing AlchemyCMS into a Rails application. By the end you will have a running Alchemy instance with an admin user.

## Prerequisites

You need a working Ruby on Rails development environment. If you are new to Rails, follow the [Install Ruby on Rails](https://guides.rubyonrails.org/install_ruby_on_rails.html) guide first.

- [Ruby](https://www.ruby-lang.org/en/documentation/installation/) >= 3.1
- [Ruby on Rails](https://rubyonrails.org) >= 7.2
- [ImageMagick](https://imagemagick.org) or [libvips](https://www.libvips.org) for image processing
- A database: [PostgreSQL](https://www.postgresql.org), [MariaDB](https://www.mariadb.org), or [SQLite](https://sqlite.org)

::: tip
Use a package manager to install system dependencies. [Homebrew](https://brew.sh) on macOS, or your Linux distribution's package manager.
:::

## Create a Rails application

If you don't have an existing Rails app, create one.

~~~ bash
gem install rails
rails new myapp
cd myapp
~~~

::: tip
See the [Rails Getting Started guide](https://guides.rubyonrails.org/getting_started.html) for more options.
:::

## Install Alchemy

Add the gem and run the installer. It will mount Alchemy in your routes, create configuration files, set up the database, and generate demo content.

~~~ bash
bundle add alchemy_cms
bin/rails alchemy:install
~~~

The installer asks for your site's primary language. Accept the defaults or enter your own.

## Authentication

Alchemy lets you choose your own authentication strategy.

**Option A: Use alchemy-devise** (recommended for new projects)

Add the gem and run its installer.

~~~ bash
bundle add alchemy-devise
bin/rails g alchemy:devise:install
~~~

**Option B: Use your existing authentication**

If your app already has a user model, configure Alchemy to use it. See the [custom authentication guide](how_to_add_custom_authentication) for details.

## Start the server

~~~ bash
bin/rails server
~~~

Open [http://localhost:3000/admin](http://localhost:3000/admin) in your browser. You will be prompted to create the first admin user.

After signing in you can start building pages. Continue with the [Elements](elements) guide to learn how to define your content structure.

## Changing the mount point

The installer automatically mounts Alchemy at the root of your application. If your app has its own routes and you want Alchemy to handle only a subpath, change the mount point in `config/routes.rb`.

~~~ ruby
# config/routes.rb
Rails.application.routes.draw do
  # your app's routes
  resources :products

  # mount Alchemy under /cms instead of /
  mount Alchemy::Engine => "/cms"
end
~~~

::: warning
Alchemy has a catch-all route for page URLs. Mount it after your own routes so they take priority.
:::

## What the installer creates

The installer generates these files in your app.

| File | Purpose |
|------|---------|
| `config/alchemy/elements.yml` | [Element](elements) definitions |
| `config/alchemy/page_layouts.yml` | [Page layout](pages) definitions |
| `config/alchemy/menus.yml` | Menu definitions |
| `config/initializers/alchemy.rb` | Alchemy [configuration](configuration) |
| `app/views/layouts/application.html.erb` | Application layout with Alchemy helpers |
| `app/views/alchemy/page_layouts/_standard.html.erb` | Demo [page layout](pages#page-layouts) partial |
| `app/views/alchemy/elements/_article.html.erb` | Demo [element](elements#rendering) partial |
| `app/assets/stylesheets/alchemy/admin/custom.css` | Custom [admin styles](configuration#admin-javascript-and-css) |
