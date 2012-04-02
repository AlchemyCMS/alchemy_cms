require 'rails'

module Alchemy
  module Generators
    class PageLayoutsGenerator < ::Rails::Generators::Base
      desc "This generator generates your page_layouts view partials."
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def create_directory
        @page_layouts_dir = "#{Rails.root}/app/views/alchemy/page_layouts"
        empty_directory @page_layouts_dir
      end

      def create_partials
        @page_layouts = get_page_layouts_from_yaml
        @page_layouts.each do |page_layout|
          @page_layout_name = page_layout["name"].underscore
          template "layout.html.erb", "#{@page_layouts_dir}/_#{@page_layout_name}.html.erb"
        end if @page_layouts
      end

      private

      def get_page_layouts_from_yaml
        YAML.load_file "#{Rails.root}/config/alchemy/page_layouts.yml"
      rescue Errno::ENOENT
        puts "\nERROR: Could not read config/alchemy/page_layouts.yml file. Please run: rails generate alchemy:scaffold"
      end

    end
  end
end
