module Alchemy
  class PageLayout
    class << self

      # Returns all page layouts.
      #
      # They are defined in +config/alchemy/page_layout.yml+ file.
      #
      def all
        @definitions ||= read_layouts_file
      end

      # Add additional page layout definitions to collection.
      #
      # Useful for extending the page layouts from an Alchemy module.
      #
      # === Usage Example
      #
      #   Call +Alchemy::PageLayout.add(your_layout_definition)+ in your engine.rb file.
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

      # Returns one page layout description by given name.
      #
      def get(name)
        return {} if name.blank?
        all.detect { |a| a['name'].downcase == name.downcase }
      end

      def get_all_by_attributes(attributes)
        return [] if attributes.blank?
        if attributes.class.name == 'Hash'
          layouts = []
          attributes.stringify_keys.each do |key, value|
            result = all.select { |a| a[key].to_s.downcase == value.to_s.downcase if a.has_key?(key) }
            layouts += result unless result.empty?
          end
          return layouts
        else
          return []
        end
      end

      # Returns page layouts ready for Rails' select form helper.
      #
      def layouts_for_select(language_id, only_layoutpages = false)
        @map_array = [[I18n.t('Please choose'), '']]
        mapped_layouts_for_select(selectable_layouts(language_id, only_layoutpages))
      end

      # Returns page layouts including given layout ready for Rails' select form helper.
      #
      def layouts_with_own_for_select(page_layout_name, language_id, only_layoutpages = false)
        layouts = selectable_layouts(language_id, only_layoutpages)
        if layouts.detect { |l| l['name'] == page_layout_name }.nil?
          @map_array = [[human_layout_name(page_layout_name), page_layout_name]]
        else
          @map_array = []
        end
        mapped_layouts_for_select(layouts)
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
        all.select { |layout|
          if only_layoutpages
            layout['layoutpage'] && layout_available?(layout)
          else
            !layout['layoutpage'] && layout_available?(layout)
          end
        }
      end

      # Returns all names of elements defined in given page layout.
      #
      def element_names_for(page_layout)
        if layout_description = get(page_layout)
          layout_description.fetch('elements', [])
        else
          Rails.logger.warn "\n+++ Warning: No Layout Description for #{page_layout} found! in page_layouts.yml\n"
          return []
        end
      end

      # Translates name for given layout
      #
      # === Translation example
      #
      #   de:
      #     alchemy:
      #       page_layout_names:
      #         products_overview: Produktübersicht
      #
      # @param [String]
      #   The layout name
      #
      def human_layout_name(layout)
        I18n.t(layout, scope: 'page_layout_names', default: layout.to_s.humanize)
      end

    private

      # Returns true if the given layout is unique and not already taken or it should be hidden.
      #
      def layout_available?(layout)
        !layout['hide'] && !already_taken?(layout) && available_on_site?(layout)
      end

      # Returns true if this layout is unique and already taken by another page.
      #
      def already_taken?(layout)
        layout['unique'] && page_with_layout_existing?(layout['name'])
      end

      # Returns true if one page already has the given layout
      #
      def page_with_layout_existing?(layout)
        Page.where(page_layout: layout, language_id: @language_id).pluck(:id).any?
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
        Site.current.layout_definition.blank? || Site.current.layout_definition.fetch('page_layouts', []).include?(layout['name'])
      end

      # Reads the layout definitions from +config/alchemy/page_layouts.yml+.
      #
      def read_layouts_file
        if File.exists?(layouts_file_path)
          YAML.load(ERB.new(File.read(layouts_file_path)).result) || []
        else
          raise LoadError, "Could not find page_layouts.yml file! Please run `rails generate alchemy:scaffold`"
        end
      end

      # Returns the page_layouts.yml file path
      #
      def layouts_file_path
        Rails.root.join 'config/alchemy/page_layouts.yml'
      end

      # Maps given layouts for Rails select form helper.
      #
      def mapped_layouts_for_select(layouts)
        layouts.each do |layout|
          @map_array << [human_layout_name(layout['name']), layout["name"]]
        end
        @map_array
      end

    end
  end
end
