# Require globally used external libraries
require 'coffee-rails'
require 'compass-rails'
require 'declarative_authorization'
require 'dynamic_form'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'rails3-jquery-autocomplete'
require 'sass-rails'
require 'sassy-buttons'
require 'userstamp'

# Require globally used Alchemy mixins
require 'alchemy/auth/engine'
require 'alchemy/auth_accessors'
require 'alchemy/config'
require 'alchemy/errors'
require 'alchemy/essence'
require 'alchemy/ferret/search'
require 'alchemy/filetypes'
require 'alchemy/i18n'
require 'alchemy/language_helpers'
require 'alchemy/logger'
require 'alchemy/modules'
require 'alchemy/mount_point'
require 'alchemy/name_conversions'
require 'alchemy/page_layout'
require 'alchemy/picture_attributes'
require 'alchemy/resource'
require 'alchemy/tinymce'

# Require hacks
require 'alchemy/kaminari/scoped_pagination_url_helper'
require File.join(File.dirname(__FILE__), '../extensions/action_view')

# Require middleware
require File.join(File.dirname(__FILE__), '../middleware/flash_session_cookie')

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
        "alchemy/tinymce_content.css",
        "alchemy/tinymce_dialog.css",
        "tiny_mce/*"
      ]
    end

    initializer 'alchemy.flash_cookie' do |config|
      config.middleware.insert_after(
        'ActionDispatch::Cookies',
        Alchemy::Middleware::FlashSessionCookie,
        ::Rails.configuration.session_options[:key]
      )
    end

    initializer "alchemy.add_authorization_rules" do
      Alchemy::Auth::Engine.get_instance.load(File.join(File.dirname(__FILE__), '../..', 'config/authorization_rules.rb'))
    end

    config.to_prepare do
      ApplicationController.send(:include, Alchemy::LanguageHelpers)
    end

    config.after_initialize do
      require 'alchemy/userstamp'
    end

  end
end
