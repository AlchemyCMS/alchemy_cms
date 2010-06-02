RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/alchemy/plugins/engines/boot')

Rails::Initializer.run do |config|
  config.gem 'ferret'
  config.gem "grosser-fast_gettext", :version => '>=0.4.8', :lib => 'fast_gettext', :source => "http://gems.github.com"
  config.gem "gettext", :lib => false, :version => '>=1.9.3'
  config.gem "rmagick", :lib => "RMagick2"
  config.gem 'mime-types', :lib => "mime/types"
  
  config.plugin_paths << File.join(File.dirname(__FILE__), '../vendor/plugins/alchemy/plugins')
  config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/alchemy/app/sweepers )
  config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/alchemy/app/middleware )
  config.i18n.load_path += Dir[Rails.root.join('vendor/plugins/alchemy/config', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :de
  config.active_record.default_timezone = :berlin
end
