# Creating Modules

Modules add custom sections to the Alchemy admin interface. Use them to manage your own models (events, products, orders) with Alchemy's built-in CRUD interface, authentication, and authorization.

You only need three things: a controller, a module registration, and routes.

## Generator

Alchemy provides a generator that creates all the necessary files:

~~~ bash
bin/rails generate alchemy:module event
~~~

This generates:

| File | Purpose |
|------|---------|
| `app/controllers/admin/events_controller.rb` | Admin controller inheriting from `ResourcesController` |
| `app/models/events_ability.rb` | CanCanCan ability for authorization |
| `config/initializers/alchemy_event.rb` | Module registration and ability registration |

It also adds the admin routes to `config/routes.rb`.

The rest of this guide explains what each piece does so you can customize or create modules manually.

## The Controller

Your module controller inherits from `Alchemy::Admin::ResourcesController`, which provides a full CRUD interface out of the box:

~~~ ruby
# app/controllers/admin/events_controller.rb
class Admin::EventsController < Alchemy::Admin::ResourcesController
end
~~~

That's it. The `ResourcesController` automatically generates index, new, create, edit, update, and destroy actions based on your model's attributes. It also handles search, pagination, sorting, and CSV export.

You can override any action or add your own logic as needed.

## Routes

Add admin routes for your resource. Make sure to define them **before** the Alchemy engine mount:

~~~ ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :admin do
    resources :events
  end

  mount Alchemy::Engine => "/"
end
~~~

::: warning
Alchemy uses a catch-all route for pages. Always mount your routes before `Alchemy::Engine`, otherwise they won't be reachable.
:::

## Module Registration

Register your module so it appears in the admin navigation. Wrap the registration in `config.to_prepare` to ensure it runs on each code reload in development:

~~~ ruby
# config/initializers/alchemy_event.rb
Rails.application.config.to_prepare do
  Alchemy::Modules.register_module(
    name: "events",
    navigation: {
      name: "Events",
      controller: "/admin/events",
      action: "index",
      icon: "calendar"
    }
  )
end
~~~

### Module Definition Options

| Option | Type | Description |
|--------|------|-------------|
| `name` | `String` | Unique module identifier |
| `navigation` | `Hash` | Navigation configuration (see [Navigation](#navigation)) |
| `engine_name` | `String` | Rails engine name for URL generation (omit for host app modules) |
| `position` | `Integer` | Sort order in the navigation sidebar (lower numbers appear higher) |

## Navigation

The `navigation` hash controls how your module appears in the admin sidebar.

### Navigation Options

| Option | Type | Description |
|--------|------|-------------|
| `name` | `String` | Display name or I18n key (e.g. `"modules.events"`) |
| `controller` | `String` | Controller path with leading slash |
| `action` | `String` | Controller action (typically `"index"`) |
| `icon` | `String` | A [Remix icon](https://remixicon.com) name (e.g. `"calendar"`, `"shopping-bag"`) |
| `icon-style` | `String` | Remix icon style: `"line"` (default), `"fill"`, or `"none"` |
| `inline_image` | `String` | Raw HTML or inline SVG for a custom icon (used instead of `icon`) |
| `image` | `String` | Path to an image asset for the icon (used instead of `icon`) |
| `params` | `Hash` | Additional URL parameters |
| `data` | `Hash` | HTML5 data attributes on the navigation entry |
| `sub_navigation` | `Array` | Array of sub-navigation entries (see [Sub-navigation](#sub-navigation)) |

::: info NOTE
The icon options are checked in order: `image`, `inline_image`, `icon`. If none is set, a default table icon is rendered.
:::

### Sub-Navigation

Add tabs within your module using `sub_navigation`:

~~~ ruby
Alchemy::Modules.register_module(
  name: "events",
  navigation: {
    name: "Events",
    controller: "/admin/events",
    action: "index",
    icon: "calendar",
    sub_navigation: [
      {
        name: "Events",
        controller: "/admin/events",
        action: "index"
      },
      {
        name: "Locations",
        controller: "/admin/locations",
        action: "index"
      }
    ]
  }
)
~~~

::: info NOTE
Each sub-navigation entry needs its own controller and routes.
:::

### Translating Navigation Names

Navigation names are translated through I18n under the `alchemy` namespace. Use a key like `modules.events` to make it translatable:

~~~ ruby
navigation: {
  name: "modules.events",
  ...
}
~~~

~~~ yaml
# config/locales/en.yml
en:
  alchemy:
    modules:
      events: Events
~~~

~~~ yaml
# config/locales/de.yml
de:
  alchemy:
    modules:
      events: Veranstaltungen
~~~

::: tip
See the [I18n guide](i18n) for all available translation scopes.
:::

## Authorization

Alchemy uses [CanCanCan](https://github.com/CanCanCommunity/cancancan) for authorization. Create an ability class and register it so Alchemy knows about your module's permissions:

~~~ ruby
# app/models/events_ability.rb
class EventsAbility
  include CanCan::Ability

  def initialize(user)
    if user.present? && user.is_admin?
      can :manage, Event
      can :manage, :admin_events
    end
  end
end
~~~

The symbol `:admin_events` is derived from the controller path -- `/admin/events` becomes `:admin_events`. This is what Alchemy checks when deciding whether to show the navigation entry.

Register the ability in the same initializer as the module:

### Alchemy 8.1+ <Badge type="tip" text="8.1+" />

~~~ ruby
# config/initializers/alchemy_event.rb
Rails.application.config.to_prepare do
  Alchemy::Modules.register_module(...)

  Alchemy.config.abilities.add("EventsAbility")
end
~~~

### Alchemy 8.0 <Badge type="warning" text="8.0" />

~~~ ruby
# config/initializers/alchemy_event.rb
Rails.application.config.to_prepare do
  Alchemy::Modules.register_module(...)

  Alchemy.register_ability(EventsAbility)
end
~~~

:::warning
`Alchemy.register_ability` is deprecated since Alchemy 8.1 and will be removed in a future version.
:::

::: tip
You can define more granular permissions by checking for specific roles instead of `is_admin?`. See the [CanCanCan documentation](https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities) for details.
:::

## Resource Form

The `ResourcesController` renders default views for all CRUD actions. You can override any view by placing a file with the same name in your app:

~~~
app/views/admin/events/
  _form.html.erb     # The form for new/edit
  _table.html.erb    # The table on the index page
  index.html.erb     # The full index page
  new.html.erb       # Rendered in the Alchemy dialog
  edit.html.erb      # Rendered in the Alchemy dialog
~~~

The default form auto-generates fields from your model's database columns. To customize it, create a `_form.html.erb` partial:

::: tip
`alchemy_form_for` is a wrapper around [Simple Form](https://github.com/heartcombo/simple_form). You can use all Simple Form input types and options.
:::

~~~ erb
<%= alchemy_form_for resource_instance_variable,
      url: resource_path(resource_instance_variable, search_filter_params) do |f| %>
  <%= f.input :name %>
  <%= f.input :starts_at, as: :date %>
  <%= f.input :description %>
  <%= f.submit Alchemy.t(:save) %>
<% end %>
~~~

## Resource Table

Alchemy renders index tables using the `Alchemy::Admin::Resource::Table` ViewComponent. Without any customization, it auto-generates columns from your model's database columns (skipping `id`, `created_at`, and `creator_id` by default) and adds edit and delete buttons. Columns are sorted with `name` first, `updated_at` last, and booleans near the end.

You can customize which attributes are skipped, restricted, or searchable by defining class methods on your model (see [Customizing attributes](#customizing-attributes)).

To customize the table rendering, create a `_table.html.erb` partial and use the component's block API:

~~~ erb
<%= render Alchemy::Admin::Resource::Table.new(
  resources_instance_variable,
  query: @query,
  search_filter_params: search_filter_params
) do |table| %>
  <% table.icon_column "calendar" %>
  <% table.column :name, sortable: true %>
  <% table.column :starts_at, sortable: true %>
  <% table.column :location do |event| %>
    <%= event.location&.name %>
  <% end %>
  <% table.edit_button %>
  <% table.delete_button %>
<% end %>
~~~

### Table Component Methods

`column(name, sortable: false, header: nil, type: nil, &block)`

Adds a table column. Without a block, the column renders the attribute value automatically. With a block, you control the cell content:

~~~ erb
<% table.column :name, sortable: true %>
<% table.column :status do |event| %>
  <span class="badge"><%= event.status %></span>
<% end %>
~~~

`icon_column(icon, style: nil, &block)`

Adds an icon column. Pass a fixed icon name or use a block to determine the icon per row:

~~~ erb
<% table.icon_column "calendar" %>
<% table.icon_column do |event| %>
  <%= event.active? ? "check" : "close" %>
<% end %>
~~~

`edit_button(tooltip: "Edit", dialog_title: nil, dialog_size: nil)`

Adds an edit button that opens the edit view in the Alchemy dialog.

`delete_button(tooltip: "Delete", confirm_message: "Are you sure?")`

Adds a delete button with a confirmation prompt.

::: tip
Alchemy uses its own admin views for pages, pictures, and attachments. You can browse them on [GitHub](https://github.com/AlchemyCMS/alchemy_cms/tree/main/app/views/alchemy/admin/resources) as a reference.
:::

## Customizing Attributes

By default, Alchemy skips `id`, `created_at`, and `creator_id` from the table and form views. You can customize this behavior by defining class methods on your model.

### Skipping Attributes

Hide attributes from both the table and the form:

~~~ ruby
class Event < ApplicationRecord
  def self.skipped_alchemy_resource_attributes
    %w[id created_at updated_at secret_token]
  end
end
~~~

### Restricting Attributes

Restricted attributes are shown in the table but cannot be edited in the form:

~~~ ruby
class Event < ApplicationRecord
  def self.restricted_alchemy_resource_attributes
    %w[synced_at external_id]
  end
end
~~~

### Searchable Attributes

By default, all `string` and `text` columns are searchable. To override:

~~~ ruby
class Event < ApplicationRecord
  def self.searchable_alchemy_resource_attributes
    %w[name description location_name]
  end
end
~~~

### Belongs-to Relations

Alchemy can display associated record names instead of foreign key IDs. Define `alchemy_resource_relations` to configure this:

~~~ ruby
class Event < ApplicationRecord
  belongs_to :location

  def self.alchemy_resource_relations
    {
      location: { attr_method: "name", attr_type: "string" }
    }
  end
end
~~~

This replaces the `location_id` column in the table and form with a select box showing each location's `name`.

## Modules in Engines

If you are packaging your module as a Rails engine, add `engine_name` to the registration so Alchemy uses the engine's routing proxy for URL generation:

~~~ ruby
Alchemy::Modules.register_module(
  name: "shop",
  engine_name: "my_shop",
  navigation: {
    name: "Shop",
    controller: "/my_shop/admin/products",
    action: "index",
    icon: "shopping-bag"
  }
)
~~~

::: info NOTE
The `engine_name` must match the name set in your `Rails::Engine` class.
:::

Mount your engine **before** Alchemy in the host app's routes:

~~~ ruby
# config/routes.rb
Rails.application.routes.draw do
  mount MyShop::Engine => "/"
  mount Alchemy::Engine => "/"
end
~~~

::: tip
The [alchemy-devise](https://github.com/AlchemyCMS/alchemy-devise) and [alchemy-solidus](https://github.com/AlchemyCMS/alchemy-solidus) extensions are good examples of engine-based modules.
:::
