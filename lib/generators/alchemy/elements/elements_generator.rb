# frozen_string_literal: true

require_relative "../base"

module Alchemy
  module Generators
    class ElementsGenerator < Base
      desc "This generator generates your elements view partials."
      source_root File.expand_path("templates", __dir__)

      def create_partials
        @elements = Alchemy::ElementDefinition.all
        @elements.each do |element|
          @element = element
          @ingredients = element.ingredients
          @element_name = element.name
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
