# frozen_string_literal: true

# AlchemyCMS Dragonfly configuration.
#
# Consider using some kind of caching solution for image processing.
# For small projects, we have good experience with Rack::Cache.
#
# Larger installations should consider using a CDN, start reading
# http://markevans.github.io/dragonfly/cache/
#
# A complete reference can be found at
# http://markevans.github.io/dragonfly/configuration/
#
# Pictures
#
Dragonfly.app(:alchemy_pictures).configure do
  dragonfly_url nil
  plugin :imagemagick
  plugin :svg
  secret '976ee38cf5e6d65dbf58f1d355825ba33239ab7a76a432818cd592526e9c78b5'
  url_format '/pictures/:job/:name.:ext'

  datastore :file,
    root_path:  Rails.root.join('uploads/pictures').to_s,
    server_root: Rails.root.join('public'),
    store_meta: false
end

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware, :alchemy_pictures

# Attachments
Dragonfly.app(:alchemy_attachments).configure do
  datastore :file,
    root_path:  Rails.root.join('uploads/attachments').to_s,
    store_meta: false
end
