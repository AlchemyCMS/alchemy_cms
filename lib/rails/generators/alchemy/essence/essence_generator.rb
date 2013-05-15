require 'rails'

module Alchemy
  module Generators
    class EssenceGenerator < ::Rails::Generators::Base
      desc "This generator generates an Alchemy essence for you."
      argument :essence_name, :banner => "YourEssenceName"
      source_root File.expand_path('templates', File.dirname(__FILE__))

      def init
        @essence_name = Alchemy::Content.normalize_essence_type(essence_name).underscore
        @essence_view_path = Rails.root.join('app/views/alchemy/essences')
      end

      def create_model
        invoke("model", [@essence_name])
      end

      def create_directory
        empty_directory @essence_view_path
      end

      def act_as_essence
        essence_class_file = Rails.root.join('app/models', "#{@essence_name}.rb")
        essence_class = @essence_name.classify
        inject_into_class essence_class_file, essence_class, <<-CLASSMETHOD
  acts_as_essence(
    # Your options:
    #
    # ingredient_column:   [String or Symbol] - Specifies the column name you use for storing the content in the database. (Default :body)
    # validate_column:     [String or Symbol] - Which column should be validated. (Default: ingredient_column)
    # preview_text_column: [String or Symbol] - Specifies the column for the preview_text method. (Default: ingredient_column)
    # preview_text_method: [String or Symbol] - A method called on ingredient to get the preview text. (Default: ingredient_column)
  )
CLASSMETHOD
      end

      def copy_templates
        essence_name = @essence_name.classify.demodulize
        template "view.html.erb", "#{@essence_view_path}/_#{essence_name}_view.html.erb"
        template "editor.html.erb", "#{@essence_view_path}/_#{essence_name}_editor.html.erb"
      end

      def show_todo
        say "\nPlease open the generated migration file and add your columns to your table."
        say "Then run 'rake db:migrate' to update your database."
        say "Also check the generated view files and alter them to fit your needs."
      end

    end
  end
end
