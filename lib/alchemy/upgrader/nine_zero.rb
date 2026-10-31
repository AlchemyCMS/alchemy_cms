# frozen_string_literal: true

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
    end
  end
end
