require 'rails'

if Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR == 0
  require 'acts_as_list'
  require 'acts-as-taggable-on'
  require 'devise'
  require 'devise-encryptable'
  require 'awesome_nested_set'
  require 'dragonfly'
  require 'dynamic_form'
  require 'jquery-rails'
  require 'jquery-ui-rails'
  require 'rails3-jquery-autocomplete'
  require 'handles_sortable_columns'
  require 'kaminari'
  require 'userstamp'
  require 'yaml'
  require 'sass-rails'
  require 'compass-rails'
  require 'coffee-rails'
  require 'sassy-buttons'
  require 'declarative_authorization'
  require 'extensions/action_view'
  require 'alchemy/mount_point'
  require 'alchemy/version'
  require 'alchemy/auth_engine'
  require 'alchemy/engine'
  require 'alchemy/picture_attributes'
  [
    'config',
    'logger',
    'errors',
    'essence',
    'page_layout',
    'modules',
    'tinymce',
    'i18n',
    'scoped_pagination_url_helper',
    'resource',
    'resources_helper',
    'ferret_search',
    'filetypes',
    'name_conversions'
  ].each do |class_name|
    require File.join(File.dirname(__FILE__), "alchemy", class_name)
  end
  require File.join(File.dirname(__FILE__), "alchemy", "seeder")
else
  raise "Alchemy #{Alchemy::VERSION} needs Rails 4.0 or higher. You are currently using Rails #{Rails::VERSION::STRING}"
end
