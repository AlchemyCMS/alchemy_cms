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
