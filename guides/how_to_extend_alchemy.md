# Extending Alchemy

At some point you may come across the need of adding some behavior to already existing controllers or models, that Alchemy provides. Obviously you could just copy the files, insert them into your projects and edit them there, but this isn't a really clean solution.

* This section will give you a hint on how to extend existing Alchemy files without overriding everything.

## Tell Rails to load our extensions

Tell Rails to load our extensions by adding some lines into `config/application.rb`

~~~ ruby
# config/application.rb
config.to_prepare do
  Dir.glob(Rails.root.join('app', '**', '*_extension.rb')) do |f|
    Rails.configuration.cache_classes ? require(f) : load(f)
  end
end
~~~

## Adding an extension

After you set up the loading for our extensions, we can actually start making some. Lets assume you want to add a before_action method to the `Alchemy::PagesController`. You go into your host app and add a file in `app/controllers/alchemy/` called `pages_controller_extension.rb`. It's important to add the `_extension` to the filename so Rails will load them.

Into this file you add the following code:

~~~ ruby
module AlchemyPagesControllerExtension
end

Alchemy::PagesController.prepend AlchemyPagesControllerExtension
~~~

Into this block you can add anything you want your controller to do. As already mentioned, we want to add a before_action to this controller for some show off. It could then look like this:

~~~ ruby
module AlchemyPagesControllerExtension
  def prepended(base)
    base.before_action :some_method, only: :show
  end
end
~~~

The last step is adding some_method to your `ApplicationController`. This is done like you are used to in Rails.
