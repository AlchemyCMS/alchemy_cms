# frozen_string_literal: true
require "rails"

module Alchemy
  module Generators
    class IngredientGenerator < ::Rails::Generators::Base
      desc "This generator generates an Alchemy ingredient class for you."
      argument :class_name, banner: "ingredient_class_name"
      source_root File.expand_path("templates", __dir__)

      def init
        @class_name = class_name.classify
        @ingredients_view_path = "app/views/alchemy/ingredients"
      end

      def create_model
        template "model.rb.tt", "app/models/alchemy/ingredients/#{file_name}.rb"
      end

      def copy_templates
        @ingredient_editor_local = "#{file_name}_editor"
        @ingredient_view_local = "#{file_name}_view"
        template "view.html.erb", "#{@ingredients_view_path}/_#{file_name}_view.html.erb"
        template "editor.html.erb", "#{@ingredients_view_path}/_#{file_name}_editor.html.erb"
      end

      def show_todo
        say "\nPlease check the generated files and alter them to fit your needs."
      end

      private

      def file_name
        @_file_name ||= @class_name.classify.demodulize.underscore
      end
    end
  end
end
