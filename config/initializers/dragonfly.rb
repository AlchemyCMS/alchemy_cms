# Alchemy CMS Dragonfly configuration.
app = Dragonfly[:alchemy_pictures]

app.configure_with :imagemagick
app.configure_with :rails
app.define_macro ActiveRecord::Base, :image_accessor

app.configure do |c|

  c.datastore.configure do |d|
    d.root_path = Rails.root.join('uploads/pictures').to_s
    d.store_meta = false
  end

  # You only need this if you use Dragonfly url helpers, what you not need to ;)
  # If you use the Dragonfly url helpers and you have a different mountpoint for Alchemy,
  # you have to alter this to include the mountpoint.
  c.url_format = '/pictures/:job/:basename.:format'

end
