require 'rails'

module Alchemy
  module Generators
    class ScaffoldGenerator < ::Rails::Generators::Base
      desc "This generator generates the Alchemy scaffold."
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def create_config_dir
        empty_directory "#{Rails.root}/config/alchemy"
      end

      def create_view_dirs
        empty_directory Rails.root.join("app/views/alchemy/elements")
        empty_directory Rails.root.join("app/views/alchemy/page_layouts")
      end

      def copy_config
        copy_file "#{config_path}/config.yml", "#{Rails.root}/config/alchemy/config.yml"
      end

      def copy_files
        copy_file "#{File.dirname(__FILE__)}/files/elements.yml", "#{Rails.root}/config/alchemy/elements.yml"
        template "page_layouts.yml.tt", "#{Rails.root}/config/alchemy/page_layouts.yml"
        copy_file "#{File.dirname(__FILE__)}/files/application.html.erb", "#{Rails.root}/app/views/layouts/application.html.erb"
      end

    private

      def config_path
        @config_path ||= File.expand_path('../../../../../config/alchemy', File.dirname(__FILE__))
      end

    end
  end
end
