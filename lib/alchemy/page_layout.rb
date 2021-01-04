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

      def get_all_by_attributes(attributes)
        return [] if attributes.blank?

        if attributes.is_a? Hash
          layouts = []
          attributes.stringify_keys.each do |key, value|
            result = all.select { |l| l.key?(key) && l[key].to_s.casecmp(value.to_s).zero? }
            layouts += result unless result.empty?
          end
          layouts
        else
          []
        end
      end

      # Returns page layouts ready for Rails' select form helper.
      #
      def layouts_for_select(language_id, only_layoutpages = false)
        @map_array = []
        mapped_layouts_for_select(selectable_layouts(language_id, only_layoutpages))
      end

      # Returns all layouts that can be used for creating a new page.
      #
      # It removes all layouts from available layouts that are unique and already taken and that are marked as hide.
      #
      # @param [Fixnum]
      #   language_id of current used Language.
      # @param [Boolean] (false)
      #   Pass true to only select layouts for global/layout pages.
      #
      def selectable_layouts(language_id, only_layoutpages = false)
        @language_id = language_id
        all.select do |layout|
          if only_layoutpages
            layout["layoutpage"] && layout_available?(layout)
          else
            !layout["layoutpage"] && layout_available?(layout)
          end
        end
      end

      # Returns all names of elements defined in given page layout.
      #
      def element_names_for(page_layout)
        if definition = get(page_layout)
          definition.fetch("elements", [])
        else
          Rails.logger.warn "\n+++ Warning: No layout definition for #{page_layout} found! in page_layouts.yml\n"
          []
        end
      end

      # Translates name for given layout
      #
      # === Translation example
      #
      #   en:
      #     alchemy:
      #       page_layout_names:
      #         products_overview: Products Overview
      #
      # @param [String]
      #   The layout name
      #
      def human_layout_name(layout)
        Alchemy.t(layout, scope: "page_layout_names", default: layout.to_s.humanize)
      end

      private

      # Returns true if the given layout is unique and not already taken or it should be hidden.
      #
      def layout_available?(layout)
        !layout["hide"] && !already_taken?(layout) && available_on_site?(layout)
      end

      # Returns true if this layout is unique and already taken by another page.
      #
      def already_taken?(layout)
        layout["unique"] && page_with_layout_existing?(layout["name"])
      end

      # Returns true if one page already has the given layout
      #
      def page_with_layout_existing?(layout)
        Alchemy::Page.where(page_layout: layout, language_id: @language_id).pluck(:id).any?
      end

      # Returns true if given layout is available for current site.
      #
      # If no site layouts are defined it always returns true.
      #
      # == Example
      #
      #   # config/alchemy/site_layouts.yml
      #   - name: default_site
      #     page_layouts: [default_intro]
      #
      def available_on_site?(layout)
        return false unless Alchemy::Site.current

        Alchemy::Site.current.definition.blank? ||
          Alchemy::Site.current.definition.fetch("page_layouts", []).include?(layout["name"])
      end

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

      # Maps given layouts for Rails select form helper.
      #
      def mapped_layouts_for_select(layouts)
        layouts.each do |layout|
          @map_array << [human_layout_name(layout["name"]), layout["name"]]
        end
        @map_array
      end
    end
  end
end
