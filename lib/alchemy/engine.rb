module Alchemy
  class Engine < Rails::Engine
    isolate_namespace Alchemy
    engine_name 'alchemy'
    config.mount_at = '/'

    initializer 'alchemy.lookup_context' do
      Alchemy::LOOKUP_CONTEXT = ActionView::LookupContext.new(Rails.root.join('app', 'views', 'alchemy'))
    end

    initializer 'alchemy.dependency_tracker' do
      [:erb, :slim, :haml].each do |handler|
        ActionView::DependencyTracker.register_tracker(handler, CacheDigests::TemplateTracker)
      end
    end

    initializer 'alchemy.non_digest_assets' do
      NonStupidDigestAssets.whitelist += [/^tinymce\//]
    end

    # Gutentag downcases all tgas before save.
    # We support having tags with uppercase characters.
    # The Gutentag search is case insensitive.
    initializer 'alchemy.gutentag_normalizer' do
      Gutentag.normaliser = ->(value) { value.to_s }
    end

    config.after_initialize do
      require_relative './userstamp'
    end

    initializer "alchemy.error_tracking" do
      if defined?(Airbrake)
        require_relative "error_tracking/airbrake_handler"
        Alchemy::ErrorTracking.notification_handler = Alchemy::ErrorTracking::AirbrakeHandler
      end
    end
  end
end
