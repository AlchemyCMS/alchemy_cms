# Alchemy CMS Dragonfly configuration.

# Pictures
Dragonfly.app(:alchemy_pictures).configure do
  plugin :imagemagick
  datastore :file,
    root_path:  Rails.root.join('uploads/pictures').to_s,
    store_meta: false
  url_format '/pictures/:job/:basename.:format'
  url_path_prefix Alchemy::MountPoint.get
end

# Attachments
Dragonfly.app(:alchemy_attachments).configure do
  datastore :file,
    root_path:  Rails.root.join('uploads/attachments').to_s,
    store_meta: false
end

# Logger
Dragonfly.logger = Rails.logger

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
