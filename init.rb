require 'extensions/hash'
require 'extensions/array'
require 'alchemy'
require 'injections/attachment_fu_mime_type'

config.after_initialize do
  ActionController::Dispatcher.middleware.insert_before(
    ActionController::Base.session_store,
    FlashSessionCookieMiddleware,
    ActionController::Base.session_options[:key]
  )
end
