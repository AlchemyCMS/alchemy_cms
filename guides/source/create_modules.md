## Creating custom Modules

Basicly there are two ways to set up a module:

* Use Alchemy as your Rails admin backend
* Create a new Engine

endprologue.


INFO: Alchemy provides a rails generator for custom modules, that can be invoked like this:
`rails generate alchemy:module your_module_name`


### Using Alchemy as your Rails admin backend

Hence every module is a subsection of a Rails application or a gem you can roll out your own admin backend if you like.

By using Alchemy's backend interface you get a whole bunch of things:

  1. Authentication and Authorization
  2. A highly and fine grained customizable resource manager (CRUD interface)
  3. A nicely styled user interface

And it's easy as this:

```ruby
module Admin
  class YourResourcesController < Alchemy::Admin::ResourcesController
  end
end
```

You can overwrite the default controller actions and views as you like.
An instance-variable named after the resource (i.e. `@your_resource` for `YourResource`) is defined for use in your views.

After you setting up your routes you have to take care for control access:

### Authorization

Rights and roles are set in a CanCan Ability model.
Create the file if it doesn't exist already. It has to be registered manually, by invoking `Alchemy.register_ability MyModuleAbility` in the module initializer.

```ruby
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
```

More information about authorization can be found in the docs of the [`cancancan` gem](https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities)

### Mounting

#### For an engine:

```ruby
# config/routes.rb
YourApp::Application.routes.draw do
  ...
  mount YourAlchemyModule::Engine => '/'
  mount Alchemy::Engine => '/'
end
```

#### For your apps resources:

```ruby
# config/routes.rb
YourApp::Application.routes.draw do

  resources :your_resource

  namespace :admin do
    resources :your_resource
  end

  mount Alchemy::Engine => '/'
end
```

INFO: Due to Alchemy's strong routes it is **strongly recommended** to mount your engine before Alchemy.

### Registering the module

Last but not least the module needs to be registered to Alchemy CMS.

#### When using your host app:

```ruby
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
```

NOTE: As an alternative to the module icon you can pass: `image: '/alchemy/icon_of_your_module.png'`

### Translate your module names:

All module names are passed through I18n within a `alchemy` namespace.
The name will be used as translation key.
You should namespace your module name (with i.e. `modules`), to prevent conflicts.

#### Example:

Given a module name `modules.products` your translation has to be:

```yaml
# config/locales/de.yml
de:
  alchemy:
    modules:
      products: Produkte
```

#### Using a Rails engine:

```ruby
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
```

### Get Ready!

Restart, point your browser to <code>localhost:3000/admin/your_resources</code>!
