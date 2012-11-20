require File.join(File.dirname(__FILE__), '../middleware/flash_session_cookie')
require File.join(File.dirname(__FILE__), 'authentication_helpers')

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

    initializer "alchemy.add_authorization_rules" do
      Alchemy::AuthEngine.get_instance.load(File.join(File.dirname(__FILE__), '../..', 'config/authorization_rules.rb'))
    end

    config.to_prepare do
      ApplicationController.send :include, Alchemy::AuthenticationHelpers
    end

  end
end
