require 'extensions/hash'
require 'extensions/form_helper'
require 'alchemy/controller'
require 'injections/attachment_fu_mime_type'

# if defined?(Authorization)
#   Authorization::AUTH_DSL_FILES = Dir.glob("#{Rails.root.to_s}/vendor/plugins/*/config/authorization_rules.rb")
# end

# ActionController::Base.cache_store = :file_store, "#{Rails.root.to_s}/tmp/cache"

# FastGettext.add_text_domain 'alchemy', :path => File.join(Rails.root.to_s, 'vendor/plugins/alchemy/locale')

# config.after_initialize do
#   ActionController::Dispatcher.middleware.insert_before(
#     ActionController::Base.session_store,
#     FlashSessionCookieMiddleware,
#     ActionController::Base.session_options[:key]
#   )
# end
