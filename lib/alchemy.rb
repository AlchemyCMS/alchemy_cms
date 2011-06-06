require 'alchemy/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
require 'extensions/hash'
require 'extensions/array'
#require 'extensions/attachment_fu_mime_type'
require 'alchemy/version'
require 'authlogic'
require 'tinymce_hammer'
require 'gettext_i18n_rails'
%w(config essence page_layout tableless controller).each do |class_name|
  require File.join(File.dirname(__FILE__), "alchemy", class_name)
end

module Alchemy
  
  class EssenceError < StandardError; end
  
end
