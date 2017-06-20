require File.join(__FILE__, '../../base')

module Alchemy
  module Generators
    class PageLayoutsGenerator < Base
      desc "This generator generates your page_layouts view partials."
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def create_partials
        @page_layouts = load_alchemy_yaml('page_layouts.yml')
        return unless @page_layouts
        @page_layouts.each do |page_layout|
          next if page_layout['redirects_to_external']
          @page_layout_name = page_layout["name"].underscore
          conditional_template "layout.html.#{template_engine}", "#{page_layouts_dir}/_#{@page_layout_name}.html.#{template_engine}"
        end
      end

      private

      def page_layouts_dir
        @_page_layouts_dir ||= "app/views/alchemy/page_layouts"
      end
    end
  end
end
