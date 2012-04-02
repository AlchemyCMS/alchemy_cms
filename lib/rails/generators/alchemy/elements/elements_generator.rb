require 'rails'

module Alchemy
  module Generators
    class ElementsGenerator < ::Rails::Generators::Base
      desc "This generator generates your elements view partials."
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def create_directory
        @elements_dir = "#{Rails.root}/app/views/alchemy/elements"
        empty_directory @elements_dir
      end

      def create_partials
        @elements = get_elements_from_yaml
        @elements.each do |element|
          @element = element
          @contents = (element["contents"] or [])
          @element_name = element["name"].underscore
          template "editor.html.erb", "#{@elements_dir}/_#{@element_name}_editor.html.erb"
          template "view.html.erb", "#{@elements_dir}/_#{@element_name}_view.html.erb"
        end if @elements
      end

      private

      def get_elements_from_yaml
        YAML.load_file "#{Rails.root}/config/alchemy/elements.yml"
      rescue Errno::ENOENT
        puts "\nERROR: Could not read config/alchemy/elements.yml file. Please run: rails generate alchemy:scaffold"
      end

    end
  end
end
