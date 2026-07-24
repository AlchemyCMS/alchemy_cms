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

    config.time_zone = "Berlin"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    # config.active_storage.variant_processor = :mini_magick
    if ENV["ALCHEMY_STORAGE_ADAPTER"] == "active_storage"
      config.active_storage.variant_processor = :vips
    end

    # This app lives inside the engine root, so rails_live_reload's own watcher
    # and a watcher rooted at the engine cover the same tree and fight over the
    # same socket. The gem offers no hook to skip its watcher, so it is disabled
    # for the length of that single initializer and restored right after.
    #
    # The window matters: disabling any earlier would also skip the middleware
    # that injects the client script, and config/initializers runs too early to
    # define an initializer at all.
    initializer "dummy.disable_live_reload_watcher",
      after: "rails_live_reload.middleware",
      before: "rails_live_reload.watcher" do
      if Rails.env.development?
        @live_reload_enabled = RailsLiveReload.enabled?
        RailsLiveReload.config.enabled = false
      end
    end

    initializer "dummy.restore_live_reload",
      after: "rails_live_reload.watcher",
      before: "rails_live_reload.configure_metrics" do
      if Rails.env.development?
        RailsLiveReload.config.enabled = @live_reload_enabled
      end
    end

    # Started late so the watch patterns from the engine's initializer are in
    # place, and so it replaces rather than joins the watcher disabled above.
    config.after_initialize do
      if Rails.env.development? && RailsLiveReload.enabled?
        require_relative "../lib/live_reload_watcher"

        Dummy::LiveReloadWatcher.init
      end
    end
  end
end
