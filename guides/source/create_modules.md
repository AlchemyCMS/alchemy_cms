Creating custom Modules
-----------------------

Basicly there are two ways to set up a module:

-   Use Alchemy as your Rails admin backend
-   Create a new Engine

endprologue.

### Using Alchemy as your Rails admin backend

Hence every module is a subsection of a Rails application or a gem you
can roll out your own admin backend if you like.

By using Alchemy’s backend interface you get a whole bunch of things:

\# Authentication and Authorization\
 \# A highly and fine grained customizable resource manager (CRUD
interface)\
 \# A nicely styled user interface

And it’s easy as this:

<ruby>\
module Admin\
 class YourResourcesController \< Alchemy::Admin::ResourcesController\
 end\
end\
</ruby>

You can overwrite the default controller actions and views as you like.\
An instance-variable named after the resource (i.e.
<code>@your\_resource</code> for <code>YourResource</code>) is defined
for use in your views.

After you setting up your routes you have to take care for control
access:

### Authorization

Rights and roles are set in <code>app/models/ability.rb</code>.\
Just create the file if it doesn’t exist already.

<ruby>

1.  app/models/ability.rb\
    class Ability\
     include CanCan::Ability

def initialize(user)\
 if !user.blank? && user.is\_admin?\
 can :manage, YourResource\
 can :manage, :admin\_your\_resource\
 end\
 end

end\
</ruby>

More information about authorization can be found in the docs of the
<code>cancan</code> gem
([https://github.com/ryanb/cancan/wiki/Defining-Abilities](https://github.com/ryanb/cancan/wiki/Defining-Abilities))

### Mounting

#### For an engine:

<ruby>

1.  config/routes.rb\
    YourApp::Application.routes.draw do\
     …\
     mount YourAlchemyModule::Engine =\> ‘/’\
     mount Alchemy::Engine =\> ‘/’\
    end\
    </ruby>

#### For your apps resources:

<ruby>

1.  config/routes.rb\
    YourApp::Application.routes.draw do

resources :your\_resource

namespace :admin do\
 resources :your\_resource\
 end

mount Alchemy::Engine =\> ‘/’\
end\
</ruby>

INFO: Due to Alchemy’s strong routes it is <strong>strongly
recommended</strong> to mount your engine before Alchemy.

### Registering the module

Last but not least the module needs to be registered to Alchemy CMS.

#### When using your host app:

<ruby>

1.  my\_host\_app/config/initializers/alchemy\_modules.rb\
    Alchemy::Modules.register\_module({\
     name: ‘name\_of\_your\_module’,\
     order: 1, \# The position in main navigation, if you have more than
    1 module.\
     navigation: {\
     name: ‘modules.products’, \# The name in the main navigation
    (translated via I18n).\
     controller: ‘/admin/products’, \# The controller that will be
    used.\
     action: ‘index’, \# The controller action that will be used.\
     icon: ‘module\_icon’, \# Class of icon that will be rendered as
    navigation icon.\
     sub\_navigation: [\
     {\
     name: ‘modules.products’, \# The name for the subnavigation tab
    (translated via I18n).\
     controller: ‘/admin/products’, \# Controller that will be used.\
     action: ‘index’ \# Controller action that will be used.\
     },\
     {\
     name: ‘modules.variants’, \# The name for the subnavigation tab
    (translated via I18n).\
     controller: ‘/admin/variants’, \# Controller that will be used.\
     action: ‘index’ \# Controller action that will be used.\
     }\
     ]\
     }\
    })\
    </ruby>

NOTE: As an alternative to the module icon you can pass:
<br><code>image: ‘/alchemy/icon\_of\_your\_module.png’</code>

##### Translate your module names:

All module names are passed through I18n within a <code>alchemy</code>
namespace.\
The name will be used as translation key.\
You should namespace your module name (with i.e. <code>modules</code>),
to prevent conflicts.

<strong>Example:</strong>

Given a module name <code>modules.products</code> your translation has
to be:

<yaml>

1.  config/locales/de.yml\
    de:\
     alchemy:\
     modules:\
     products: Produkte\
    </yaml>

#### Using a Rails engine:

<ruby>

1.  my\_engine/config/initializers/alchemy.rb\
    Alchemy::Modules.register\_module({\
     name: ‘name\_of\_your\_module’,\
     engine\_name: ‘name\_of\_your\_engine’ \# The engine\_name set in
    your Rails::Engine class.\
     order: 1, \# The position in main navigation, if you have more than
    1 module.\
     navigation: {\
     name: ‘modules.products’, \# The name in the main navigation
    (translated via I18n).\
     controller: ‘/admin/products’, \# The controller that will be
    used.\
     action: ‘index’, \# The controller action that will be used.\
     icon: ‘module\_icon’, \# Class of icon that will be rendered as
    navigation icon.\
     sub\_navigation: [\
     {\
     name: ‘modules.products’, \# The name for the subnavigation tab
    (translated via I18n).\
     controller: ‘/admin/products’, \# Controller that will be used.\
     action: ‘index’ \# Controller action that will be used.\
     },\
     {\
     name: ‘modules.variants’, \# The name for the subnavigation tab
    (translated via I18n).\
     controller: ‘/admin/variants’, \# Controller that will be used.\
     action: ‘index’ \# Controller action that will be used.\
     }\
     ]\
     }\
    })

<!-- -->

1.  Loading authorization rules and register them to auth engine
    instance\
    Alchemy::Auth::Engine.get\_instance.load(File.join(File.dirname(*FILE*),
    ‘authorization\_rules.rb’))\
    </ruby>

### Get Ready!

Restart, point your browser to
<code>localhost:3000/admin/your\_resources</code>!

 
