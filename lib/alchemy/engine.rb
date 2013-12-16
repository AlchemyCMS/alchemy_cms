# Require globally used external libraries
require 'actionpack/page_caching'
require 'action_view/dependency_tracker'
require 'cancan'
require 'coffee-rails'
require 'compass-rails'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'sass-rails'
require 'sassy-buttons'
require 'simple_form'
require 'select2-rails'
require 'turbolinks'
require 'userstamp'
require 'non-stupid-digest-assets'

# Require globally used Alchemy mixins
require_relative './auth_accessors'
require_relative './cache_digests/template_tracker'
require_relative './config'
require_relative './errors'
require_relative './essence'
require_relative './filetypes'
require_relative "./forms/builder"
require_relative './i18n'
require_relative './logger'
require_relative './modules'
require_relative './mount_point'
require_relative './name_conversions'
require_relative './page_layout'
require_relative './permissions'
require_relative './picture_attributes'
require_relative './resource'
require_relative './tinymce'
require_relative './touching'

# Require hacks
require_relative './kaminari/scoped_pagination_url_helper'
require_relative '../extensions/action_view'

module Alchemy
  class Engine < Rails::Engine
    isolate_namespace Alchemy
    engine_name 'alchemy'
    config.mount_at = '/'

    # Enabling assets precompiling
    initializer 'alchemy.assets' do |app|
      app.config.assets.precompile += [
        "alchemy/alchemy.js",
        "alchemy/preview.js",
        "alchemy/admin.css",
        "alchemy/menubar.css",
        "alchemy/menubar.js",
        "alchemy/print.css",
        "tinymce/*"
      ]
    end

    initializer 'alchemy.dependency_tracker' do |app|
      [:erb, :slim, :haml].each do |handler|
        ActionView::DependencyTracker.register_tracker(handler, CacheDigests::TemplateTracker)
      end
    end

    initializer 'alchemy.non_digest_assets' do |app|
      NonStupidDigestAssets.whitelist = ['tinymce/']
    end

    config.after_initialize do
      require_relative './userstamp'
      # We need to reload the routes, because alchemy extensions (i.e. alchemy-devise) prepends routes.
      Rails.application.routes_reloader.reload!
    end
  end
end
