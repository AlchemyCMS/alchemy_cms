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

      # The attachment uploader used to accept every file type.
      def notify_attachment_filetypes_default
        default = Alchemy::Configurations::Uploader::AllowedFileTypes::DEFAULT_ATTACHMENT_FILE_TYPES
        current = Alchemy.config.uploader.allowed_filetypes.alchemy_attachments.to_a
        return unless current == default || current.include?("*")

        closing = if current.include?("*")
          <<~TEXT.strip
            Your app configures `["*"]`, so it still accepts every file type.
            Please consider adopting the new default.
          TEXT
        else
          <<~TEXT.strip
            Setting it back to `["*"]` restores the old behaviour and disables
            file type validation entirely.
          TEXT
        end

        todo(<<~TODO.strip, "Attachment uploads are now restricted to an allowlist")
          The `uploader.allowed_filetypes.alchemy_attachments` setting used to
          default to `["*"]`, which accepts every file type, including
          executables. It now defaults to a list of document, media and archive
          formats:

          #{default.each_slice(8).map { |slice| "  #{slice.join(" ")}" }.join("\n")}

          Please check whether your editors upload file types that are not on
          this list. If they do, add them in `config/initializers/alchemy.rb`:

            config.uploader.allowed_filetypes.alchemy_attachments = %w[#{default.first(3).join(" ")} ...]

          #{closing}
        TODO
      end

      def notify_admin_content_security_policy
        todo(<<~TODO.strip, "The admin now sends a Content Security Policy")
          If you have inline scripts or anything else in your admin that a CSP
          would block, subclass `Alchemy::Admin::ContentSecurityPolicy`, or set
          `config.admin_content_security_policy = nil` to turn it off.
        TODO
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
