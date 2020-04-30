# frozen_string_literal: true
module Alchemy
  class Engine < Rails::Engine
    isolate_namespace Alchemy
    engine_name "alchemy"
    config.mount_at = "/"

    initializer "alchemy.lookup_context" do
      Alchemy::LOOKUP_CONTEXT = ActionView::LookupContext.new(Rails.root.join("app", "views", "alchemy"))
    end

    initializer "alchemy.admin.preview_url" do
      Alchemy::Admin::PREVIEW_URL = Alchemy::Admin::PreviewUrl.new(routes: Alchemy::Engine.routes)
    end

    initializer "alchemy.dependency_tracker" do
      [:erb, :slim, :haml].each do |handler|
        ActionView::DependencyTracker.register_tracker(handler, CacheDigests::TemplateTracker)
      end
    end

    initializer "alchemy.non_digest_assets" do
      NonStupidDigestAssets.whitelist += [/^tinymce\//]
    end

    # Gutentag downcases all tgas before save.
    # We support having tags with uppercase characters.
    # The Gutentag search is case insensitive.
    initializer "alchemy.gutentag_normalizer" do
      Gutentag.normaliser = ->(value) { value.to_s }
    end

    # Custom Ransack sort arrows
    initializer "alchemy.ransack" do
      Ransack.configure do |config|
        config.custom_arrows = {
          up_arrow: '<i class="fa fas fa-xs fa-arrow-up"></i>',
          down_arrow: '<i class="fa fas fa-xs fa-arrow-down"></i>',
        }
      end
    end

    if Rails.env.development?
      initializer "alchemy.webpacker.proxy" do |app|
        app.middleware.insert_before(
          0,
          Webpacker::DevServerProxy,
          ssl_verify_none: true,
          webpacker: Alchemy.webpacker,
        )
      end
    end

    # Serve webpacks if public file server enabled
    initializer "alchemy.webpacker.middleware" do |app|
      if app.config.public_file_server.enabled
        app.middleware.use(
          Rack::Static,
          urls: ["/alchemy-packs", "/alchemy-packs-test"],
          root: Alchemy::ROOT_PATH.join("public"),
        )
      end
    end

    config.after_initialize do
      require_relative "./userstamp"
    end
  end
end
