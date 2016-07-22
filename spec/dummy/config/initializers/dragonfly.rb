# AlchemyCMS Dragonfly configuration.
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
  url_format '/pictures/:job/:sha/:basename.:ext'

  datastore :file,
    root_path:  Rails.root.join('uploads/pictures').to_s,
    server_root: Rails.root.join('public'),
    store_meta: false

  # If caching is enabled in host app, we store the rendered
  # image into `public/pictures`, so the webserver can pick it up
  # and serve it directly to the client.
  #
  # Please feel free to change this to fit your needs:
  # http://markevans.github.io/dragonfly/cache/
  #
  before_serve do |job, env|
    if Rails.application.config.action_controller.perform_caching
      path = env['PATH_INFO'].sub(/^\//, '')
      job.to_file(Rails.root.join('public', Alchemy::MountPoint.get, path))
    end
  end
end

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware, :alchemy_pictures

# Attachments
Dragonfly.app(:alchemy_attachments).configure do
  datastore :file,
    root_path:  Rails.root.join('uploads/attachments').to_s,
    store_meta: false
end
