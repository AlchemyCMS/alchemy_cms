# frozen_string_literal: true
require_relative '../base'

module Alchemy
  module Generators
    class ElementsGenerator < Base
      desc "This generator generates your elements view partials."
      source_root File.expand_path('templates', __dir__)

      def create_partials
        @elements = load_alchemy_yaml('elements.yml')
        return unless @elements

        @elements.each do |element|
          @element = element
          @contents = element["contents"] || []
          if element["name"] =~ /\A[a-z0-9_-]+\z/
            @element_name = element["name"].underscore
          else
            raise "Element name '#{element['name']}' has wrong format. Only lowercase and non whitespace characters allowed."
          end

          conditional_template "view.html.#{template_engine}", "#{elements_dir}/_#{@element_name}.html.#{template_engine}"
        end
      end

      private

      def elements_dir
        @_elements_dir ||= "app/views/alchemy/elements"
      end
    end
  end
end
