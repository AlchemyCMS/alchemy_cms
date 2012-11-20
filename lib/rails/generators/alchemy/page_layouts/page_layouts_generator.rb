require File.join(__FILE__, '../../base')

module Alchemy
  module Generators
    class PageLayoutsGenerator < Base
      desc "This generator generates your page_layouts view partials."
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def create_directory
        @page_layouts_dir = "#{Rails.root}/app/views/alchemy/page_layouts"
        empty_directory @page_layouts_dir
      end

      def create_partials
        @page_layouts = load_alchemy_yaml('page_layouts.yml')
        @page_layouts.each do |page_layout|
          @page_layout_name = page_layout["name"].underscore
          conditional_template "layout.html.#{template_engine}", "#{@page_layouts_dir}/_#{@page_layout_name}.html.#{template_engine}"
        end if @page_layouts
      end
    end
  end
end
