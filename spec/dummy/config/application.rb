require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
if ENV['FAST_SPECS']
  require "active_record/railtie"
  require "action_controller/railtie"
  require "action_mailer/railtie"
  require "active_resource/railtie"
  require "alchemy_cms"
else
  require "active_record/railtie"
  require "action_controller/railtie"
  require "action_mailer/railtie"
  require "active_resource/railtie"
  require "sprockets/railtie"
end

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  # Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  if ENV['FAST_SPECS']
    Bundler.require(:test)
  else
    Bundler.require(:default, :assets, Rails.env)
  end
end

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end
