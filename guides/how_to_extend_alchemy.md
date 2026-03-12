# Extending Alchemy

Alchemy has extensive [configuration](configuration) options and class-level extension points, but sometimes you need to go further. This guide is about using Alchemy's helpers in your own controllers, and adding behavior to Alchemy's built-in controllers and models.

## Using Alchemy in Your Controllers

If your app has controllers that render Alchemy content or use Alchemy view helpers like `render_elements` or `render_menu`, include `Alchemy::ControllerActions`:

~~~ ruby
# app/controllers/blog_controller.rb
class BlogController < ApplicationController
  include Alchemy::ControllerActions
end
~~~

This gives your controller access to:

- `current_alchemy_site` and `set_alchemy_language`
- Alchemy's page and element view helpers
- `current_alchemy_user` and `alchemy_user_signed_in?`

## Extending Alchemy Controllers

To add behavior to an Alchemy controller, use Ruby's `prepend` inside a `config.to_prepare` block. This ensures the extension is reloaded in development.

~~~ ruby
# config/initializers/alchemy_extensions.rb
Rails.application.config.to_prepare do
  Alchemy::PagesController.prepend(PagesControllerExtension)
end
~~~

~~~ ruby
# app/models/pages_controller_extension.rb
module PagesControllerExtension
  def self.prepended(base)
    base.before_action :track_visit, only: :show
  end

  private

  def track_visit
    # your custom logic
  end
end
~~~

## Extending Alchemy Models

The same pattern works for models:

~~~ ruby
# config/initializers/alchemy_extensions.rb
Rails.application.config.to_prepare do
  Alchemy::Page.prepend(PageExtension)
end
~~~

~~~ ruby
# app/models/page_extension.rb
module PageExtension
  def self.prepended(base)
    base.scope :featured, -> { where(page_layout: "featured") }
    base.after_publish :notify_subscribers
  end

  private

  def notify_subscribers
    # your custom logic
  end
end
~~~

::: tip
`config.to_prepare` runs on every request in development and once in production, so your extensions are always in sync with code reloads.
:::
