require 'declarative_authorization'
plugin_authorization_files = Dir.glob("#{Rails.root.to_s}/vendor/plugins/*/config/authorization_rules.rb")
plugin_authorization_files << File.join(File.dirname(__FILE__), '..', 'authorization_rules.rb')
Authorization::AUTH_DSL_FILES = plugin_authorization_files