if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'alchemy/engine'
  require 'extensions/hash'
  require 'extensions/array'
  require 'extensions/action_view'
  require 'alchemy/version'
  require 'authlogic'
  require 'will_paginate'
  require 'tinymce_hammer'
  require 'gettext_i18n_rails'
  require 'userstamp'
  %w(config essence page_layout controller).each do |class_name|
    require File.join(File.dirname(__FILE__), "alchemy", class_name)
  end
  require File.join(File.dirname(__FILE__), "alchemy", "seeder")
else
  raise "Alchemy 2.0 needs Rails 3.0 or higher. You are currently using Rails #{Rails::VERSION::MAJOR}"
end

module Alchemy
  
  class EssenceError < StandardError; end
  
end
