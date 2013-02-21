# Alchemy CMS Dragonfly configuration.

# Pictures
pictures = Dragonfly[:alchemy_pictures]
pictures.configure_with :imagemagick
pictures.configure_with :rails
pictures.define_macro ActiveRecord::Base, :image_accessor
pictures.configure do |config|
  config.datastore.configure do |store|
    store.root_path = Rails.root.join('uploads/pictures').to_s
    store.store_meta = false
  end
  # You only need this if you use Dragonfly url helpers, what you not need to ;)
  # If you use the Dragonfly url helpers and you have a different mountpoint for Alchemy,
  # you have to alter this to include the mountpoint.
  config.url_format = '/pictures/:job/:basename.:format'
end

# Attachments
attachments = Dragonfly[:alchemy_attachments]
attachments.configure_with :rails
attachments.define_macro ActiveRecord::Base, :file_accessor
attachments.configure do |config|
  config.datastore.configure do |store|
    store.root_path = Rails.root.join('uploads/attachments').to_s
    store.store_meta = false
  end
end
