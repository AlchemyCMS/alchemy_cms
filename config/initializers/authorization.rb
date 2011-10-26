require 'declarative_authorization'
Authorization::AUTH_DSL_FILES += File.join(File.dirname(__FILE__), '..', 'authorization_rules.rb')