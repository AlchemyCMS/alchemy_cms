require 'rails'

module Alchemy
  module Generators
    class ScaffoldGenerator < ::Rails::Generators::Base
      desc "This generator generates the Alchemy scaffold. Pass --with-standard-set to copy Alchemys standard set into your app."
      class_option :with_standard_set, :type => :boolean, :desc => "Copy standard set files."
      source_root File.expand_path('templates', File.dirname(__FILE__))
      
      def create_config_dir
        empty_directory "#{Rails.root}/config/alchemy"
      end
      
      def copy_config
        @config_path = File.expand_path('../../../../../config/alchemy', File.dirname(__FILE__)) 
        copy_file "#{@config_path}/config.yml", "#{Rails.root}/config/alchemy/config.yml"
      end
      
      def copy_yamls
        if options['--with-standard-set']
          layouts_path = File.expand_path('../../../../../app/views/layouts', File.dirname(__FILE__)) 
          copy_file "#{@config_path}/elements.yml", "#{Rails.root}/config/alchemy/elements.yml"
          copy_file "#{@config_path}/page_layouts.yml", "#{Rails.root}/config/alchemy/page_layouts.yml"
          copy_file "#{layouts_path}/pages.html.erb", "#{Rails.root}/app/views/layouts/pages.html.erb"
          Rails::Generators.invoke("alchemy:elements")
          Rails::Generators.invoke("alchemy:page_layouts")
        else
          template "elements.yml", "#{Rails.root}/config/alchemy/elements.yml"
          template "page_layouts.yml", "#{Rails.root}/config/alchemy/page_layouts.yml"
        end
      end
      
    end
  end
end
