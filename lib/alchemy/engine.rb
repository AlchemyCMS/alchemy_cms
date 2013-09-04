# Require globally used external libraries
require 'coffee-rails'
require 'compass-rails'
require 'devise'
require 'dynamic_form'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'rails3-jquery-autocomplete'
require 'sass-rails'
require 'sassy-buttons'

# Require globally used alchemy mixins
require 'alchemy/auth/engine'
require 'alchemy/config'
require 'alchemy/errors'
require 'alchemy/i18n'
require 'alchemy/kaminari/scoped_pagination_url_helper'
require 'alchemy/logger'
require 'alchemy/page_layout'
require 'alchemy/tinymce'

# Require hacks
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

    # filter sensitive information during logging
    initializer "alchemy.params.filter" do |app|
      app.config.filter_parameters += [:password, :password_confirmation]
    end

  end
end
