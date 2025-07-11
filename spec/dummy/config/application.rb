# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "active_job/railtie"
require "active_storage/engine"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require "alchemy_cms"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    if config.respond_to?(:load_defaults)
      config.load_defaults ENV["RAILS_VERSION"] || 8.0
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    # config.active_storage.variant_processor = :mini_magick
    if ENV["ALCHEMY_STORAGE_ADAPTER"] == "active_storage"
      config.active_storage.variant_processor = :vips
    end
  end
end
