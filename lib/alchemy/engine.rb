# frozen_string_literal: true

module Alchemy
  class Engine < Rails::Engine
    isolate_namespace Alchemy
    engine_name "alchemy"
    config.mount_at = "/"

    initializer "alchemy.lookup_context" do
      Alchemy::LOOKUP_CONTEXT = ActionView::LookupContext.new(Rails.root.join("app", "views", "alchemy"))
    end

    initializer "alchemy.dependency_tracker" do
      [:erb, :slim, :haml].each do |handler|
        ActionView::DependencyTracker.register_tracker(handler, CacheDigests::TemplateTracker)
      end
    end

    initializer "alchemy.assets" do |app|
      if defined?(Sprockets)
        require_relative "../non_stupid_digest_assets"
        NonStupidDigestAssets.whitelist += [/^tinymce\//]
        app.config.assets.precompile << "alchemy_manifest.js"
      end
    end

    initializer "alchemy.admin_stylesheets" do |app|
      if defined?(Sprockets)
        Alchemy.admin_stylesheets.each do |stylesheet|
          app.config.assets.precompile << stylesheet
        end
      end
    end

    initializer "alchemy.propshaft" do |app|
      if defined?(Propshaft)
        if app.config.assets.server
          # Monkey-patch Propshaft::Asset to enable access
          # of TinyMCE assets without a hash digest.
          require_relative "propshaft/tinymce_asset"
        end
      end
    end

    initializer "alchemy.importmap" do |app|
      watch_paths = []

      Alchemy.admin_importmaps.each do |admin_import|
        Alchemy.importmap.draw admin_import[:importmap_path]
        watch_paths += admin_import[:source_paths]
        app.config.assets.paths += admin_import[:source_paths]
        if admin_import[:name] != "alchemy_admin"
          Alchemy.admin_js_imports.add(admin_import[:name])
        end
      end

      if app.config.importmap.sweep_cache
        Alchemy.importmap.cache_sweeper(watches: watch_paths)
        ActiveSupport.on_load(:action_controller_base) do
          before_action { Alchemy.importmap.cache_sweeper.execute_if_updated }
        end
      end
    end

    initializer "alchemy.watch_definition_changes" do |app|
      elements_reloader = app.config.file_watcher.new([ElementDefinition.definitions_file_path]) do
        Rails.logger.info "[#{engine_name}] Reloading Element Definitions."
        ElementDefinition.reset!
      end
      page_layouts_reloader = app.config.file_watcher.new([PageLayout.layouts_file_path]) do
        Rails.logger.info "[#{engine_name}] Reloading Page Layouts."
        PageLayout.reset!
      end
      [elements_reloader, page_layouts_reloader].each do |reloader|
        app.reloaders << reloader
        app.reloader.to_run do
          reloader.execute_if_updated
        end
      end
    end

    # Gutentag downcases all tags before save
    # and Gutentag validations are not case sensitive.
    # But we support having tags with uppercase characters.
    config.to_prepare do
      Gutentag.normaliser = ->(value) { value.to_s }
      Gutentag.tag_validations = Alchemy::TagValidations
    end

    # Custom Ransack sort arrows
    initializer "alchemy.ransack" do
      Ransack.configure do |config|
        config.custom_arrows = {
          up_arrow: '<alchemy-icon name="arrow-up" size="1x"></alchemy-icon>',
          down_arrow: '<alchemy-icon name="arrow-down" size="1x"></alchemy-icon>'
        }
      end
    end

    initializer "alchemy.config_yml" do |app|
      config_directory = Rails.root.join("config", "alchemy")
      Alchemy::Config.set_from_yaml(
        config_directory.join("config.yml")
      )
      Alchemy::Config.set_from_yaml(
        config_directory.join("#{Rails.env}.config.yml")
      )
    end

    config.after_initialize do
      if Alchemy.user_class
        ActiveSupport.on_load(:active_record) do
          Alchemy.user_class.model_stamper
          Alchemy.user_class.stampable(stamper_class_name: Alchemy.user_class.name)
        end
      end

      if defined?(RailsLiveReload) && Rails.env.development?
        require "alchemy/dev_support/live_reload_watcher"

        Alchemy::LiveReloadWatcher.init
      end
    end

    initializer "alchemy.webp-mime_type" do
      # Rails does not know anything about webp even in 2022
      unless Mime::Type.lookup_by_extension(:webp)
        Mime::Type.register("image/webp", :webp)
      end
      # Dragonfly uses Rack to read the mime type and guess what
      unless Rack::Mime::MIME_TYPES[".webp"]
        Rack::Mime::MIME_TYPES[".webp"] = "image/webp"
      end
    end
  end
end
