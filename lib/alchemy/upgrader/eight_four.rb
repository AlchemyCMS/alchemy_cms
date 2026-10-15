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

      NAVIGATION_PARTIALS = %w[
        app/views/alchemy/admin/_main_navi.html.erb
        app/views/alchemy/admin/partials/_main_navigation_entry.html.erb
        app/views/alchemy/admin/partials/_sub_navigation.html.erb
      ].freeze

      # +Alchemy::Modules.register_module+ is deprecated in favor of
      # +Alchemy.config.menu+. Calls with a static literal argument are
      # rewritten, everything else has to be migrated by hand.
      def upgrade_menu_config
        rewritten = []
        manual = []
        rewriter = begin
          require "prism"
          RegisterModuleRewriter.new
        rescue LoadError
          nil
        end

        Dir.glob(Rails.root.join("config/initializers/**/*.rb")).sort.each do |file|
          content = File.read(file)
          next unless content.include?("register_module")

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

        overridden_partials = NAVIGATION_PARTIALS.map { |partial| Rails.root.join(partial).to_s }.select { |file| File.exist?(file) }

        list = ->(files) { files.map { |file| "  - #{Pathname.new(file).relative_path_from(Rails.root)}" }.join("\n") }

        if rewritten.any?
          todo(<<~TODO.strip, "`register_module` calls were rewritten to `Alchemy.config.menu.add`")
            `Alchemy::Modules.register_module` is deprecated and will be removed in
            Alchemy 9.0. We rewrote its calls in the following initializers to
            `Alchemy.config.menu.add`:

            #{list.call(rewritten)}

            Please review these changes and commit them.
          TODO
        end

        if manual.any?
          todo(<<~TODO.strip, "The admin main navigation is now configured with `Alchemy.config.menu`")
            `Alchemy::Modules.register_module` is deprecated and will be removed in
            Alchemy 9.0. The following initializers call it in a way we could not
            rewrite automatically:

            #{list.call(manual)}

            Please replace these `register_module` calls with
            `Alchemy.config.menu.add` in `config/initializers/alchemy.rb`:

              Alchemy.configure do |config|
                config.menu.add(
                  name: "events",
                  title: "Events",
                  icon: "calendar",
                  url: -> { main_app.admin_events_path },
                  condition: -> { can?(:index, :admin_events) },
                  children: [
                    {
                      title: "Locations",
                      url: -> { main_app.admin_locations_path },
                      condition: -> { can?(:index, :admin_locations) }
                    }
                  ]
                )
              end

            `url` and `condition` are evaluated in the view context. The keys of
            the former `navigation` hash now live on the entry itself, its `name`
            is now `title`, `sub_navigation` is now `children`, `icon-style` is now
            `icon_style`, `data: {turbo: false}` is now `turbo: false`, and `params`
            is no longer supported.

            Call `config.menu.add` once at boot and not inside `to_prepare`, as it
            does not skip entries that are already present like `register_module`
            did.
          TODO
        end

        if overridden_partials.any?
          todo(<<~TODO.strip, "The admin main navigation partials have been replaced")
            Your app overrides the following partials, which have been replaced by
            the `Alchemy::Admin::MainNavigation` components and are no longer
            rendered:

            #{list.call(overridden_partials)}

            Please adapt your changes.
          TODO
        end
      end
    end
  end
end
