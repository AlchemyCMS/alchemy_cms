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
          up_arrow: '<i class="fa fas fa-xs fa-arrow-up"></i>',
          down_arrow: '<i class="fa fas fa-xs fa-arrow-down"></i>',
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
