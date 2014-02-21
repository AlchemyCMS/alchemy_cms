require File.join(__FILE__, '../../base')

module Alchemy
  module Generators
    class ElementsGenerator < Base
      desc "This generator generates your elements view partials."
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def create_directory
        @elements_dir = "#{Rails.root}/app/views/alchemy/elements"
        empty_directory @elements_dir
      end

      def create_partials
        @elements = load_alchemy_yaml('elements.yml')
        @elements.each do |element|
          @element = element
          contents = element["contents"] || []
          if @element['available_contents']
            @available_contents_names = @element['available_contents'].collect { |c| c['name'] }
            @contents = contents.delete_if { |c| @available_contents_names.include?(c['name']) } or []
          else
            @contents = contents
          end
          if element["name"] =~ /\A[a-z0-9_-]+\z/
            @element_name = element["name"].underscore
          else
            raise "Element name '#{element['name']}' has wrong format. Only lowercase and non whitespace characters allowed."
          end

          conditional_template "editor.html.#{template_engine}", "#{@elements_dir}/_#{@element_name}_editor.html.#{template_engine}"
          conditional_template "view.html.#{template_engine}", "#{@elements_dir}/_#{@element_name}_view.html.#{template_engine}"
        end if @elements
      end
    end
  end
end
