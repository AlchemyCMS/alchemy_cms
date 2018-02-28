module Alchemy
  class Engine < Rails::Engine
    isolate_namespace Alchemy
    engine_name 'alchemy'
    config.mount_at = '/'

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

    # We need to reload each essence class in development mode on every request,
    # so it can register itself as essence relation on Page and Element models
    #
    # @see lib/alchemy/essence.rb:71
    config.to_prepare do
      unless Rails.configuration.cache_classes
        essences = File.join(File.dirname(__FILE__), '../../app/models/alchemy/essence_*.rb')
        Dir.glob(essences).each { |essence| load(essence) }
      end
    end

    config.after_initialize do
      require_relative './userstamp'
    end
  end
end
