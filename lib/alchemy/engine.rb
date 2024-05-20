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

    initializer "alchemy.non_digest_assets" do
      NonStupidDigestAssets.whitelist += [/^tinymce\//]
    end

    initializer "alchemy.importmap" do |app|
      watch_paths = []

      Alchemy.engine_importmaps.each do |engine|
        Alchemy.importmap.draw engine.root.join("config/alchemy", "importmap.rb")
        package_path = engine.root.join("app/javascript")
        watch_paths << package_path
        vendor_packages_path = engine.root.join("vendor/javascript")
        app.config.assets.paths += [package_path, vendor_packages_path]
        if engine.engine_name != "alchemy"
          Alchemy.admin_js_imports.add(engine.engine_name)
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
