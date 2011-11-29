require 'rails'

module Alchemy
  module Generators
    class PluginGenerator < ::Rails::Generators::Base
      desc "This generator generates a Alchemy plugin skeleton for you."
      argument :plugin_name, :banner => "your_plugin_name"
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def create_directories
        @plugin_name = plugin_name.underscore
        @plugin_path = Rails.root.join('vendor/plugins', @plugin_name)
        empty_directory "#{@plugin_path}/lib/#{@plugin_name}"
        empty_directory "#{@plugin_path}/rails"
        empty_directory "#{@plugin_path}/app/controllers/admin"
        empty_directory "#{@plugin_path}/app/models"
        empty_directory "#{@plugin_path}/app/views/admin"
        empty_directory "#{@plugin_path}/config/alchemy"
        empty_directory "#{@plugin_path}/config/initializers"
        empty_directory "#{@plugin_path}/locale/de"
        empty_directory "#{@plugin_path}/locale/en"
      end

      def create_defaults
        copy_file("#{File.dirname(__FILE__)}/files/translation.pot", "#{@plugin_path}/locale/#{@plugin_name}.pot")
        copy_file("#{File.dirname(__FILE__)}/files/translation_de.po", "#{@plugin_path}/locale/de/#{@plugin_name}.po")
        copy_file("#{File.dirname(__FILE__)}/files/translation_en.po", "#{@plugin_path}/locale/en/#{@plugin_name}.po")
        template("config.yml", "#{@plugin_path}/config/alchemy/config.yml")
        template("authorization_rules.rb", "#{@plugin_path}/config/authorization_rules.rb")
        template("routes.rb", "#{@plugin_path}/config/routes.rb")
        template("plugin.rb", "#{@plugin_path}/lib/#{@plugin_name}.rb")
        template("init.rb", "#{@plugin_path}/rails/init.rb")
      end

    end
  end
end
