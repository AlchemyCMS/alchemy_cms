# frozen_string_literal: true

module Alchemy
  class PageLayout
    class << self
      # Returns all page layouts.
      #
      # They are defined in +config/alchemy/page_layout.yml+ file.
      #
      def all
        @definitions ||= read_definitions_file
      end

      # Add additional page definitions to collection.
      #
      # Useful for extending the page layouts from an Alchemy module.
      #
      # === Usage Example
      #
      #   Call +Alchemy::PageLayout.add(your_definition)+ in your engine.rb file.
      #
      # @param [Array || Hash]
      #   You can pass a single layout definition as Hash, or a collection of page layouts as Array.
      #
      def add(page_layout)
        all
        if page_layout.is_a?(Array)
          @definitions += page_layout
        elsif page_layout.is_a?(Hash)
          @definitions << page_layout
        else
          raise TypeError
        end
      end

      # Returns one page definition by given name.
      #
      def get(name)
        return {} if name.blank?

        all.detect { |a| a["name"].casecmp(name).zero? }
      end

      private

      # Reads the layout definitions from +config/alchemy/page_layouts.yml+.
      #
      def read_definitions_file
        if File.exist?(layouts_file_path)
          YAML.safe_load(ERB.new(File.read(layouts_file_path)).result, YAML_WHITELIST_CLASSES, [], true) || []
        else
          raise LoadError, "Could not find page_layouts.yml file! Please run `rails generate alchemy:install`"
        end
      end

      # Returns the page_layouts.yml file path
      #
      def layouts_file_path
        Rails.root.join "config/alchemy/page_layouts.yml"
      end
    end
  end
end
