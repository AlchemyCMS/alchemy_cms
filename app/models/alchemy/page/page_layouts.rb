# frozen_string_literal: true

module Alchemy
  class Page < BaseRecord
    # Module concerning page layouts
    #
    module PageLayouts
      extend ActiveSupport::Concern

      module ClassMethods
        # Returns page layouts ready for Rails' select form helper.
        #
        def layouts_for_select(language_id, only_layoutpages = false)
          @map_array = []
          mapped_layouts_for_select(selectable_layouts(language_id, only_layoutpages))
        end

        # Returns page layouts including given layout ready for Rails' select form helper.
        #
        def layouts_with_own_for_select(page_layout_name, language_id, only_layoutpages = false)
          layouts = selectable_layouts(language_id, only_layoutpages)
          if layouts.detect { |l| l["name"] == page_layout_name }.nil?
            @map_array = [[human_layout_name(page_layout_name), page_layout_name]]
          else
            @map_array = []
          end
          mapped_layouts_for_select(layouts)
        end

        deprecate :layouts_with_own_for_select, deprecator: Alchemy::Deprecation

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
          Alchemy::PageLayout.all.select do |layout|
            if only_layoutpages
              layout["layoutpage"] && layout_available?(layout)
            else
              !layout["layoutpage"] && layout_available?(layout)
            end
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

        # Maps given layouts for Rails select form helper.
        #
        def mapped_layouts_for_select(layouts)
          layouts.each do |layout|
            @map_array << [human_layout_name(layout["name"]), layout["name"]]
          end
          @map_array
        end

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
      end
    end
  end
end
