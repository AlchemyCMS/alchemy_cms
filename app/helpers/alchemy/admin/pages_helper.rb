# frozen_string_literal: true

module Alchemy
  module Admin
    module PagesHelper
      include Alchemy::Admin::BaseHelper

      # Returns screen sizes for the preview size select in page edit view.
      #
      # You can configure the screen sizes in your +config/alchemy/config.yml+.
      #
      def preview_sizes_for_select
        Alchemy.config.page_preview_sizes.map do |size|
          [Alchemy.t(size, scope: "preview_sizes"), size]
        end
      end

      # Renders a label for page's page layout
      #
      # If the page layout definition of the page is missing, it displays a warning.
      #
      def page_layout_label(page)
        if page.persisted? && page.definition.blank?
          [
            page_layout_missing_warning,
            Alchemy.t(:page_type)
          ].join("&nbsp;").html_safe
        else
          Alchemy.t(:page_type)
        end
      end

      def page_status_checkbox(page, attribute)
        label = page.class.human_attribute_name(attribute)
        checkbox = if page.attribute_fixed?(attribute)
          content_tag("sl-tooltip", class: "like-hint-tooltip", content: Alchemy.t(:attribute_fixed, attribute: attribute), placement: "bottom-start") do
            check_box_tag("page[#{attribute}]", "1", page.send(attribute), disabled: true)
          end
        else
          check_box(:page, attribute)
        end

        content_tag(:label, class: "checkbox") { "#{checkbox}\n#{label}".html_safe }
      end
    end
  end
end
