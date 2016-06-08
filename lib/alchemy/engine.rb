# Require globally used external libraries
require 'actionpack/page_caching'
require 'acts_as_list'
require 'acts-as-taggable-on'
require 'action_view/dependency_tracker'
require 'active_model_serializers'
require 'awesome_nested_set'
require 'bourbon'
require 'cancan'
require 'dragonfly'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'non-stupid-digest-assets'
require 'ransack'
require 'request_store'
require 'responders'
require 'sass-rails'
require 'simple_form'
require 'select2-rails'
require 'turbolinks'
require 'userstamp'

# Require globally used Alchemy mixins
require_relative './ability_helper'
require_relative './admin/locale'
require_relative './auth_accessors'
require_relative './cache_digests/template_tracker'
require_relative './config'
require_relative './configuration_methods'
require_relative './controller_actions'
require_relative './errors'
require_relative './essence'
require_relative './filetypes'
require_relative './forms/builder'
require_relative './hints'
require_relative './i18n'
require_relative './logger'
require_relative './modules'
require_relative './mount_point'
require_relative './name_conversions'
require_relative './on_page_layout'
require_relative './on_page_layout/callbacks_runner'
require_relative './page_layout'
require_relative './paths'
require_relative './permissions'
require_relative './picture_attributes'
require_relative './ssl_protection'
require_relative './resource'
require_relative './tinymce'
require_relative './touching'

# Require hacks
require_relative './kaminari/scoped_pagination_url_helper'

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
