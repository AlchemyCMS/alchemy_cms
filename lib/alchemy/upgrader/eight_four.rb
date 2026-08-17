# frozen_string_literal: true

module Alchemy
  class Upgrader
    module EightFour
      # Alchemy does not depend on the dragonfly gem anymore.
      # Apps still using the dragonfly storage adapter need to
      # declare the gem in their own Gemfile.
      def add_dragonfly_gem
        return unless Alchemy.storage_adapter.dragonfly?

        run %(bundle add dragonfly --version "~> 1.4")
      end

      # Element partials that render nested elements through the
      # +nested_elements+ association issue one database query per parent
      # element. Rendering through the block helper's +nested_elements+
      # instead reuses the page version's preloaded element set.
      def upgrade_nested_elements_rendering
        rewritten = []
        manual = []
        Dir.glob(Rails.root.join("app/views/alchemy/elements/*")).each do |file|
          next unless File.file?(file)

          content = File.read(file)
          block_variable = content[/element_view_for\b.*?do\s*\|\s*(\w+)\s*\|/m, 1]

          if block_variable
            pattern = /render\s+(?!#{block_variable}\b)\w+\.nested_elements(?:\.published)?/
            if content.match?(pattern)
              gsub_file(file, pattern, "render #{block_variable}.nested_elements")
              rewritten << file
            end
          elsif content.match?(/render\s+\w+\.nested_elements/)
            manual << file
          end
        end

        list = ->(files) { files.map { |file| "  - #{Pathname.new(file).relative_path_from(Rails.root)}" }.join("\n") }

        if rewritten.any?
          todo(<<~TODO.strip, "Nested elements are now rendered through the block helper")
            We rewrote the following element partials to render nested elements
            through the `element_view_for` block helper instead of the
            `nested_elements` association, which issues one query per element:

            #{list.call(rewritten)}

            Please review these changes and commit them. Also check your views
            for other uses of `element.nested_elements` that were not rewritten
            automatically (for example assigned to a variable first).
          TODO
        end

        if manual.any?
          todo(<<~TODO.strip, "Nested elements rendered outside a block helper")
            The following element partials render nested elements through the
            `nested_elements` association but not inside an `element_view_for`
            block, so we could not rewrite them automatically:

            #{list.call(manual)}

            Please render them through the block helper (`render el.nested_elements`)
            so nested rendering reuses the preloaded element set instead of
            querying per parent.
          TODO
        end
      end
    end
  end
end
