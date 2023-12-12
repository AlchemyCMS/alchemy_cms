# frozen_string_literal: true

module Alchemy
  module Admin
    module PagesHelper
      include Alchemy::Admin::BaseHelper

      # Returns options tags for the screen sizes select in page edit view.
      #
      def preview_sizes_for_select
        options_for_select([
          "auto",
          [Alchemy.t("240", scope: "preview_sizes"), 240],
          [Alchemy.t("320", scope: "preview_sizes"), 320],
          [Alchemy.t("480", scope: "preview_sizes"), 480],
          [Alchemy.t("768", scope: "preview_sizes"), 768],
          [Alchemy.t("1024", scope: "preview_sizes"), 1024],
          [Alchemy.t("1280", scope: "preview_sizes"), 1280]
        ])
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
