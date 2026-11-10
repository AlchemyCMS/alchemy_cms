---
prev: false
next: false
---

# How To: Integrate Into an Existing Rails App

This guide covers integrating AlchemyCMS into a Rails application that already has its own routes, controllers, and views. If you are starting a new project, see [Getting Started](getting_started) instead.

## Install Alchemy

Add the gem and run the installer with `--skip-demo-files` to avoid overwriting your existing layout and views.

~~~ bash
bundle add alchemy_cms
bin/rails alchemy:install --skip-demo-files
~~~

The installer mounts Alchemy in your routes, creates [configuration files](getting_started#what-the-installer-creates), sets up the database, and seeds the default site and language.

## Authentication

Alchemy needs to know which users can access the admin. Point it to your user model and authentication:

~~~ ruby
# config/initializers/alchemy.rb
Alchemy.configure do |config|
  config.user_class = "User"
  config.current_user_method = "current_user"
  config.login_path = "/login"
  config.logout_path = "/logout"
end
~~~

Your user model must respond to `alchemy_roles` and return an array of role names:

~~~ ruby
class User < ApplicationRecord
  def alchemy_roles
    admin? ? %w[admin] : %w[editor]
  end
end
~~~

See the [custom authentication guide](how_to_add_custom_authentication) for the full list of required methods and configuration options.

## Routing

The installer mounts Alchemy at the root path by default. Since Alchemy has a catch-all route for pages, it must be mounted **after** your own routes.

~~~ ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :products
  resources :orders

  mount Alchemy::Engine => "/"
end
~~~

::: warning
If Alchemy is mounted before your routes, its catch-all will intercept requests meant for your controllers.
:::

### Mounting at a Subpath

If you prefer Alchemy to handle only a portion of your site, mount it at a subpath:

~~~ ruby
mount Alchemy::Engine => "/cms"
~~~

The admin interface is then available at `/cms/admin` and Alchemy pages are served under `/cms/...`.

## Layout

Alchemy renders pages through your `application.html.erb` layout. Add the Alchemy meta data partial and the edit mode bar to your existing layout:

~~~ erb
<!DOCTYPE html>
<html>
  <head>
    <!-- your existing head content -->
    <%= render "alchemy/pages/meta_data" if @page %>
  </head>
  <body>
    <!-- your existing body content -->
    <%= yield %>
    <%= render "alchemy/edit_mode" if @page %>
  </body>
</html>
~~~

The `if @page` guard ensures these partials only render on Alchemy-managed pages and don't interfere with your own controllers.

::: tip
The meta data partial sets `<title>` and `<meta name="description">` from the current Alchemy page.
:::

## Using Alchemy Helpers

If your own controllers need access to Alchemy's view helpers (like `render_menu` for navigation or `current_alchemy_site`), include the `ControllerActions` module:

~~~ ruby
class ApplicationController < ActionController::Base
  include Alchemy::ControllerActions
end
~~~

This gives you:

| Helper | Purpose |
|--------|---------|
| `render_menu` | Render an Alchemy navigation menu |
| `render_breadcrumb` | Render a breadcrumb trail |
| `current_alchemy_site` | The current site based on the request host |
| `Current.language` | The current language |

::: tip
If you only need Alchemy helpers in specific controllers, include the module there instead of in `ApplicationController`.
:::

### Rendering Alchemy Menus in Your Layout

A common use case is rendering an Alchemy-managed navigation menu in your application layout, shared across both your own pages and Alchemy pages:

~~~ erb
<!-- app/views/layouts/application.html.erb -->
<nav>
  <%= render_menu do |node| %>
    <%= link_to node.name, node.url,
        class: node.active?(request) ? "active" : nil %>
  <% end %>
</nav>
~~~

See the [Menus guide](menus) for more rendering options.

## Administrate App Resources

Alchemy's admin interface is not limited to CMS content. You can add your own models (events, products, orders) as admin modules with full CRUD views, search, pagination, and authorization built in.

~~~ ruby
# app/controllers/admin/events_controller.rb
class Admin::EventsController < Alchemy::Admin::ResourcesController
end
~~~

Register the module and it appears in the admin sidebar alongside pages, images, and other Alchemy modules.

See the [Custom Modules guide](how_to_create_modules) for the full setup including routes, module registration, authorization, and view customization.

## Next Steps

- [Elements](elements) — define your content structure
- [Pages](pages) — configure page layouts
- [Configuration](configuration) — customize Alchemy's behavior
- [Custom Authentication](how_to_add_custom_authentication) — connect your existing user model
- [Custom Modules](how_to_create_modules) — manage your own models in the Alchemy admin
