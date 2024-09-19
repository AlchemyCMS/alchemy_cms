# Creating custom Modules

Basicly there are two ways to set up a module:

* Use Alchemy as your Rails admin backend
* Create a new Engine

## Generator

Alchemy provides a rails generator for custom modules, that can be invoked like this

~~~ bash
bin/rails generate alchemy:module your_module_name
~~~

## Using Alchemy as your Rails admin backend

Hence every module is a subsection of a Rails application or a gem you can roll out your own admin backend if you like.

By using Alchemy's backend interface you get a whole bunch of things:

  1. Authentication and Authorization
  2. A highly and fine grained customizable resource manager (CRUD interface)
  3. A nicely styled user interface

And it's easy as this:

~~~ ruby
module Admin
  class YourResourcesController < Alchemy::Admin::ResourcesController
  end
end
~~~

You can overwrite the default controller actions and views as you like.
An instance-variable named after the resource (i.e. `@your_resource` for `YourResource`) is defined for use in your views.

After you setting up your routes you have to take care for control access:

## Authorization

Rights and roles are set in a CanCan Ability model.
Create the file if it doesn't exist already. It has to be registered manually, by invoking `Alchemy.register_ability MyModuleAbility` in the module initializer.

~~~ ruby
# app/models/my_module_ability.rb
class MyModuleAbility
  include CanCan::Ability

  def initialize(user)
    if !user.blank? && user.is_admin?
      can :manage, YourResource
      can :manage, :admin_your_resources
    end
  end

end
~~~

More information about authorization can be found in the docs of the [`cancancan` gem](https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities)

## Routing

### In an engine

~~~ ruby
# config/routes.rb
YourApp::Application.routes.draw do
  ...
  mount YourAlchemyModule::Engine => '/'
  mount Alchemy::Engine => '/'
end
~~~

### In your app

~~~ ruby
# config/routes.rb
YourApp::Application.routes.draw do

  resources :your_resource

  namespace :admin do
    resources :your_resource
  end

  mount Alchemy::Engine => '/'
end
~~~

::: tip
Due to Alchemy's strong routes it is **strongly recommended** to mount your engine before Alchemy.
:::

## Registering the module

Last but not least the module needs to be registered to AlchemyCMS.

### When using your host app

~~~ ruby
# my_host_app/config/initializers/alchemy_modules.rb
Alchemy::Modules.register_module({
  name: 'name_of_your_module',
  order: 1,                             # The position in main navigation, if you have more than 1 module.
  navigation: {
    name: 'modules.products',           # The name in the main navigation (translated via I18n).
    controller: '/admin/products',      # The controller that will be used.
    action: 'index',                    # The controller action that will be used.
    icon: 'module_icon',                # Class of icon that will be rendered as navigation icon.
    sub_navigation: [
      {
        name: 'modules.products',       # The name for the subnavigation tab (translated via I18n).
        controller: '/admin/products',  # Controller that will be used.
        action: 'index'                 # Controller action that will be used.
      },
      {
        name: 'modules.variants',       # The name for the subnavigation tab (translated via I18n).
        controller: '/admin/variants',  # Controller that will be used.
        action: 'index'                 # Controller action that will be used.
      }
    ]
  }
})

# Register the module ability
Alchemy.register_ability MyModuleAbility
~~~

NOTE: As an alternative to the module icon you can pass: `image: '/alchemy/icon_of_your_module.png'`

### Using a Rails engine

~~~ ruby
# my_engine/config/initializers/alchemy.rb
Alchemy::Modules.register_module({
  name: 'name_of_your_module',
  engine_name: 'name_of_your_engine'    # The engine_name set in your Rails::Engine class.
  order: 1,                             # The position in main navigation, if you have more than 1 module.
  navigation: {
    name: 'modules.products',           # The name in the main navigation (translated via I18n).
    controller: '/admin/products',      # The controller that will be used.
    action: 'index',                    # The controller action that will be used.
    icon: 'module_icon',                # Class of icon that will be rendered as navigation icon.
    sub_navigation: [
      {
        name: 'modules.products',       # The name for the subnavigation tab (translated via I18n).
        controller: '/admin/products',  # Controller that will be used.
        action: 'index'                 # Controller action that will be used.
      },
      {
        name: 'modules.variants',       # The name for the subnavigation tab (translated via I18n).
        controller: '/admin/variants',  # Controller that will be used.
        action: 'index'                 # Controller action that will be used.
      }
    ]
  }
})

# Register the module ability
Alchemy.register_ability MyModuleAbility
~~~

## Translate your module names

All module names are passed through I18n within a `alchemy` namespace.
The name will be used as translation key.
You should namespace your module name (with i.e. `modules`), to prevent conflicts.

### Example

Given a module name `modules.products` your translation has to be:

~~~ yaml
# config/locales/de.yml
de:
  alchemy:
    modules:
      products: Produkte
~~~

## Customizing the built in views

Alchemy makes use of Rails templates and partials to render your model's resource views. You can overwrite each of them in your app or engine.

Just place a file with the same name in your `app/views/admin/plural-name-of-your-resource/` folder and Rails will pick that up instead of the Alchemy one.

You can find the list of all templates and partials Alchemy provides [on GitHub](https://github.com/AlchemyCMS/alchemy_cms/tree/7.2-stable/app/views/alchemy/admin/resources).

### The resource form

Alchemy uses [a `_form` partial](https://github.com/AlchemyCMS/alchemy_cms/blob/7.2-stable/app/views/alchemy/admin/resources/_form.html.erb) to render the fields for your resource's edit view.

It looks like this

```erb
<%= alchemy_form_for resource_instance_variable, url: resource_path(resource_instance_variable, search_filter_params) do |f| %>
  <% resource_handler.editable_attributes.each do |attribute| %>
    <% if relation = attribute[:relation] %>
      <%= f.association relation[:name].to_sym,
        collection: relation[:collection],
        label_method: relation[:attr_method],
        include_blank: Alchemy.t(:blank, scope: 'resources.relation_select'),
        input_html: {is: 'alchemy-select'} %>
    <% elsif attribute[:type].in? %i[date time datetime] %>
      <%= f.datepicker attribute[:name], resource_attribute_field_options(attribute) %>
    <% elsif attribute[:enum].present? %>
      <%= f.input attribute[:name],
        collection: attribute[:enum],
        include_blank: Alchemy.t(:blank, scope: 'resources.relation_select'),
        input_html: {is: 'alchemy-select'} %>
    <% else %>
      <%= f.input attribute[:name], resource_attribute_field_options(attribute) %>
    <% end %>
  <% end %>
  <% if f.object.respond_to?(:tag_list) %>
    <%= render Alchemy::Admin::TagsAutocomplete.new do %>
      <%= f.input :tag_list, input_html: { value: f.object.tag_list.join(",") } %>
    <% end %>
  <% end %>
  <%= f.submit Alchemy.t(:save) %>
<% end %>
```

To customize the form place a file with the same content into your apps view folder and adjust it to your needs.

### The resource table

Alchemy uses [a `_table` partial](https://github.com/AlchemyCMS/alchemy_cms/blob/7.2-stable/app/views/alchemy/admin/resources/_table.html.erb) to render the table for your resource's index view.

The default table looks like this

```erb
<% if resources_instance_variable.any? %>
<table class="list" id="<%= resource_handler.resources_name %>_list">
  <thead>
    <tr>
    <% if local_assigns[:icon] %>
      <th class="icon"></th>
    <% end %>
    <% resource_handler.sorted_attributes.each do |attribute| %>
      <th class="<%= attribute[:type] %> <%= attribute[:name] %>">
        <%= sort_link [:resource_url_proxy, @query],
          sortable_resource_header_column(attribute),
          resource_handler.model.human_attribute_name(attribute[:name]),
          default_order: attribute[:type].to_s =~ /date|time/ ? 'desc' : 'asc' %>
      </th>
    <% end %>
      <th class="tools"></th>
    </tr>
  </thead>
  <tbody>
    <%= render_resources(icon: local_assigns[:icon]) %>
  </tbody>
</table>
<% elsif search_filter_params[:q].present? %>
<p><%= Alchemy.t('Nothing found') %></p>
<% end %>

<%= paginate resources_instance_variable, scope: resource_url_proxy, theme: 'alchemy' %>
```

You can customize it by adding a `_table.html.erb` partial into your resources view folder of your app or engine and adjust it accordingly.

### Examples

Alchemy dogfeeds it's own resource views to render it's admin interface. You can take them as example as starting point.
