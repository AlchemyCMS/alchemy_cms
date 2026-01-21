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
        Alchemy.config.admin_stylesheets.each do |stylesheet|
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

    initializer "alchemy.admin_importmap" do
      Alchemy.config.admin_importmaps.add(
        importmap_path: root.join("config/importmap.rb"),
        source_paths: [
          root.join("app/javascript"),
          root.join("vendor/javascript")
        ],
        name: "alchemy_admin"
      )
    end

    initializer "alchemy.importmap" do |app|
      app.config.to_prepare do
        watch_paths = []

        Alchemy.config.admin_importmaps.each do |admin_import|
          Alchemy.importmap.draw admin_import.importmap_path
          watch_paths += admin_import.source_paths.to_a
          app.config.assets.paths += admin_import.source_paths.to_a
          if admin_import[:name] != "alchemy_admin"
            Alchemy.config.admin_js_imports.add(admin_import.name)
          end
        end

        if app.config.importmap.sweep_cache
          Alchemy.importmap.cache_sweeper(watches: watch_paths)
          ActiveSupport.on_load(:action_controller_base) do
            before_action { Alchemy.importmap.cache_sweeper.execute_if_updated }
          end
        end
      end
    end

    # All the initialization that needs to be re-triggered during reloads
    config.to_prepare do
      # Definition files
      elements_reloader = Rails.application.config.file_watcher.new([ElementDefinition.definitions_file_path]) do
        Logger.info "Reloading Element Definitions."
        ElementDefinition.reset!
      end
      page_layouts_reloader = Rails.application.config.file_watcher.new([PageDefinition.layouts_file_path]) do
        Logger.info "Reloading Page Layouts."
        PageDefinition.reset!
      end
      [elements_reloader, page_layouts_reloader].each do |reloader|
        Rails.application.reloaders << reloader
        Rails.application.reloader.to_run do
          reloader.execute_if_updated
        end
      end

      # The storage adapter for Pictures and Attachments
      #
      # Chose between 'active_storage' (default) or 'dragonfly' (legacy)
      #
      # Can be set via 'ALCHEMY_STORAGE_ADAPTER' env var.
      Alchemy.storage_adapter = Alchemy::StorageAdapter.new(
        ENV.fetch("ALCHEMY_STORAGE_ADAPTER", Alchemy.config.storage_adapter)
      )

      # Gutentag downcases all tags before save
      # and Gutentag validations are not case sensitive.
      # But we support having tags with uppercase characters.
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

      ActiveSupport.on_load(:active_storage_blob) do
        ActiveStorage::Blob.define_singleton_method(:ransackable_attributes) do |_auth_object|
          %w[filename]
        end
      end
    end

    # Load Alchemy configuration from YAML files
    # in config/alchemy/config.yml and config/alchemy/#{Rails.env}.config.yml
    # if they exist.
    # This has to be done before any app initializers are loaded, so that
    # the configuration is available in all initializers.
    initializer "alchemy.config_yml", before: :load_config_initializers do |app|
      config_directory = Rails.root.join("config", "alchemy")
      main_config = config_directory.join("config.yml")
      env_specific_config = config_directory.join("#{Rails.env}.config.yml")
      if File.exist?(main_config)
        Alchemy.config.set_from_yaml(main_config)
      end
      if File.exist?(env_specific_config)
        Alchemy.config.set_from_yaml(env_specific_config)
      end
    end

    config.after_initialize do
      if Alchemy.user_class
        ActiveSupport.on_load(:active_record) do
          Alchemy.user_class.model_stamper
          Alchemy.user_class.stampable(stamper_class_name: Alchemy.user_class_name)
        end
      end

      if defined?(RailsLiveReload) && Rails.env.development?
        require "alchemy/dev_support/live_reload_watcher"

        Alchemy::LiveReloadWatcher.init
      end
    end

    initializer "alchemy.webp-mime_type" do |app|
      webp = "image/webp"
      svg = "image/svg+xml"

      # Dragonfly uses Rack to read the mime type and guess what
      # Rack 3.0 has this included, but Rails 8 still allows Rack 2.2
      unless Rack::Mime::MIME_TYPES[".webp"]
        Rack::Mime::MIME_TYPES[".webp"] = webp
      end

      if app.config.active_storage
        # Rails sends svg images as attachment instead of inline.
        # We want to display svgs and not download them.
        unless app.config.active_storage.content_types_allowed_inline.include? svg
          app.config.active_storage.content_types_allowed_inline += [svg]
        end
        # Rails renders SVG as binary for security reasons.
        # We sanitize SVGs on upload and therefore can serve them as image.
        if app.config.active_storage.content_types_to_serve_as_binary.include? svg
          app.config.active_storage.content_types_to_serve_as_binary.delete(svg)
        end
      end
    end
  end
end
