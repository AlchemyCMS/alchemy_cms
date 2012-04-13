require 'rails'

module Alchemy
  module Generators
    class ScaffoldGenerator < ::Rails::Generators::Base
      desc "This generator generates the Alchemy scaffold. Pass --with-standard-set to copy Alchemys Standardset files into your app."
      class_option 'with-standard-set', :type => :boolean, :desc => "Copy standard set files."
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def create_config_dir
        empty_directory "#{Rails.root}/config/alchemy"
      end

      def create_view_dirs
        empty_directory Rails.root.join("app/views/alchemy/elements")
        empty_directory Rails.root.join("app/views/alchemy/page_layouts")
      end

      def copy_config
        @config_path = File.expand_path('../../../../../config/alchemy', File.dirname(__FILE__))
        copy_file "#{@config_path}/config.yml", "#{Rails.root}/config/alchemy/config.yml"
      end

      def copy_files
        if options['with-standard-set']
          layouts_path = File.expand_path('../../../../../app/views/layouts/alchemy', File.dirname(__FILE__))
          elements_path = File.expand_path('../../../../../app/views/alchemy/elements', File.dirname(__FILE__))
          page_layouts_path = File.expand_path('../../../../../app/views/alchemy/page_layouts', File.dirname(__FILE__))
          copy_file "#{@config_path}/elements.yml", "#{Rails.root}/config/alchemy/elements.yml"
          copy_file "#{@config_path}/page_layouts.yml", "#{Rails.root}/config/alchemy/page_layouts.yml"
          copy_file "#{layouts_path}/pages.html.erb", "#{Rails.root}/app/views/layouts/application.html.erb"
          Dir.glob("#{elements_path}/*").reject { |file_path| !(File.basename(file_path) =~ /(.+)_(view|editor).html.erb/) }.each do |file_path|
            copy_file file_path, "#{Rails.root}/app/views/alchemy/elements/#{File.basename(file_path)}"
          end
          directory "#{page_layouts_path}/", "#{Rails.root}/app/views/alchemy/page_layouts/"
        else
          copy_file "#{File.dirname(__FILE__)}/files/elements.yml", "#{Rails.root}/config/alchemy/elements.yml"
          copy_file "#{File.dirname(__FILE__)}/files/page_layouts.yml", "#{Rails.root}/config/alchemy/page_layouts.yml"
          copy_file "#{File.dirname(__FILE__)}/files/pages.html.erb", "#{Rails.root}/app/views/layouts/alchemy/pages.html.erb"
        end
      end

    end
  end
end
