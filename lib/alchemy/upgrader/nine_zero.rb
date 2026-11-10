# frozen_string_literal: true

require "alchemy/tasks/tidy"

module Alchemy
  class Upgrader
    module NineZero
      # The +position+ of menu entries has been removed in favor of the
      # order of +Alchemy.config.menu+. Calls with a literal position are
      # rewritten, everything else has to be migrated by hand.
      def upgrade_menu_positions
        rewritten = []
        manual = []
        rewriter = begin
          require "prism"
          MenuPositionRewriter.new
        rescue LoadError
          nil
        end

        Dir.glob(Rails.root.join("config/initializers/**/*.rb")).sort.each do |file|
          content = File.read(file)
          next unless content.include?("menu") && content.include?("position")

          unless rewriter
            manual << file
            next
          end

          new_content, rewritten_count, manual_count = rewriter.rewrite(content)
          if rewritten_count > 0
            File.write(file, new_content)
            rewritten << file
          end
          manual << file if manual_count > 0
        end

        list = ->(files) { files.map { |file| "  - #{Pathname.new(file).relative_path_from(Rails.root)}" }.join("\n") }

        if rewritten.any?
          todo(<<~TODO.strip, "The `position` of menu entries was removed")
            The admin main navigation now lists its entries in the order of
            `Alchemy.config.menu`. We removed the `position` from the menu entries
            in the following initializers and insert entries that were positioned
            between Alchemy's own entries with `Alchemy.config.menu.insert`:

            #{list.call(rewritten)}

            Please review the order of your menu entries and commit these changes.
          TODO
        end

        if manual.any?
          todo(<<~TODO.strip, "The `position` of menu entries has been removed")
            The admin main navigation now lists its entries in the order of
            `Alchemy.config.menu`. The following initializers may set a `position`
            on menu entries that we could not remove automatically:

            #{list.call(manual)}

            Please remove the `position` and use `config.menu.insert` to place an
            entry between Alchemy's own entries:

              Alchemy.configure do |config|
                # Between Languages and Sites
                config.menu.insert(4,
                  name: "events",
                  title: "Events",
                  url: -> { main_app.admin_events_path }
                )
              end
          TODO
        end
      end

      # Ingredient editor partials are not rendered anymore. ERB partials are
      # moved into the template of an editor component, everything else has
      # to be migrated by hand.
      def migrate_ingredient_editor_partials
        migrated = []
        manual = []
        rewriter = IngredientEditorPartialRewriter.new
        components_path = Rails.root.join("app/components/alchemy/ingredients")

        Dir.glob(Rails.root.join("app/views/alchemy/ingredients/_*_editor.html.*")).sort.each do |file|
          local_name = File.basename(file).delete_prefix("_").split(".").first
          component_file = components_path.join("#{local_name}.rb")
          template_file = components_path.join("#{local_name}.html.erb")

          if component_file.exist? ||
              template_file.exist? ||
              Alchemy::Engine.root.join("app/components/alchemy/ingredients/#{local_name}.rb").exist?
            manual << file
            next
          end

          unless file.end_with?(".erb")
            ingredient_name = local_name.delete_suffix("_editor")
            # The generator classifies the name, which would singularize ie. "settings".
            if ingredient_name.classify == ingredient_name.camelize
              require "rails/generators"
              require "generators/alchemy/ingredient/ingredient_generator"
              generator = Alchemy::Generators::IngredientGenerator.new(
                [ingredient_name],
                {quiet: Alchemy::Shell.silenced?},
                destination_root: Rails.root
              )
              generator.init
              generator.create_editor_component
              manual << component_file.to_s
            end
            manual << file
            next
          end

          template, needs_review = rewriter.rewrite(File.read(file), local_name)
          components_path.mkpath
          File.write(template_file, template)
          File.write(component_file, <<~RUBY)
            # frozen_string_literal: true

            module Alchemy
              module Ingredients
                class #{local_name.camelize} < BaseEditor
                end
              end
            end
          RUBY
          File.delete(file)
          migrated << template_file.to_s
          manual << template_file.to_s if needs_review
        end

        list = ->(files) { files.map { |file| "  - #{Pathname.new(file).relative_path_from(Rails.root)}" }.join("\n") }

        if migrated.any?
          todo(<<~TODO.strip, "Ingredient editor partials were migrated into components")
            Alchemy renders ingredient editors with view components inheriting from
            `Alchemy::Ingredients::BaseEditor` only. We moved your ingredient editor
            partials into the templates of new editor components:

            #{list.call(migrated)}

            The methods of the former `Alchemy::IngredientEditor` local are methods
            of the component now and `element_form.fields_for` was replaced with
            `fields_for` and `ingredient_id_field`. Please review the templates and
            render `<%= validation_error %>` to display validation errors.
          TODO
        end

        if manual.any?
          todo(<<~TODO.strip, "Ingredient editor partials are not rendered anymore")
            Alchemy renders ingredient editors with view components inheriting from
            `Alchemy::Ingredients::BaseEditor` only. Please migrate these files
            into editor components by hand:

            #{list.call(manual)}

            Override `input_field` to render a custom input or add a template
            next to the component, where `element_form` is not available anymore.
            Editor components listed above were generated with
            `bin/rails g alchemy:ingredient` for you to start from. Delete the
            partials once migrated.
          TODO
        end
      end

      def remove_deprecated_columns
        connection = ActiveRecord::Base.connection
        deprecated_columns_exist = Alchemy::Tidy::DEPRECATED_COLUMNS.any? do |table, columns|
          columns.any? { connection.column_exists?(table, _1) }
        end
        return unless deprecated_columns_exist

        desc "Deprecated columns"
        if yes?("Remove the deprecated page metadata and element public columns now? (y/N)")
          Alchemy::Tidy.remove_deprecated_columns
        else
          todo <<~TODO, "Remove deprecated columns"
            `alchemy_pages.title`, `meta_description` and `meta_keywords` moved to
            page versions in Alchemy 8.1 and `alchemy_elements.public` was replaced
            by publication timestamps in 8.4. Alchemy ignores these columns.

            Remove them with:

                bin/rails alchemy:tidy:remove_deprecated_columns
          TODO
        end
      end
    end
  end
end
