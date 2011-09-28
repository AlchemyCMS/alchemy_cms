require 'rails'

module Alchemy
  module Generators
    class PluginGenerator < ::Rails::Generators::Base
      desc "This generator generates a Alchemy plugin skeleton for you."
      argument :plugin_name, :banner => "your_plugin_name"
      source_root File.expand_path('templates', File.dirname(__FILE__))
      
      def create_directories
        @plugin_path = File.join(Rails.root, 'vendor', 'plugins', plugin_name.underscore)
        empty_directory "#{@plugin_path}/app/controllers/admin"
        empty_directory "#{@plugin_path}/app/models"
        empty_directory "#{@plugin_path}/app/views/admin"
        empty_directory "#{@plugin_path}/config/alchemy"
        empty_directory "#{@plugin_path}/locale"
      end
      
      def create_defaults
        @plugin_name = plugin_name
        template("init.rb", "#{@plugin_path}/init.rb")
        template("config.yml", "#{@plugin_path}/config/alchemy/config.yml")
        template("authorization_rules.rb", "#{@plugin_path}/config/authorization_rules.rb")
        template("routes.rb", "#{@plugin_path}/config/routes.rb")
      end
      
    end
  end
end
