module Alchemy
  module Admin
    module PagesHelper
      include Alchemy::BaseHelper

      # Returns options tags for the screen sizes select in page edit view.
      #
      def preview_sizes_for_select
        options_for_select([
          'auto',
          [Alchemy.t('240', scope: 'preview_sizes'), 240],
          [Alchemy.t('320', scope: 'preview_sizes'), 320],
          [Alchemy.t('480', scope: 'preview_sizes'), 480],
          [Alchemy.t('768', scope: 'preview_sizes'), 768],
          [Alchemy.t('1024', scope: 'preview_sizes'), 1024],
          [Alchemy.t('1280', scope: 'preview_sizes'), 1280]
        ])
      end

      # Returns the translated explanation of the page status.
      #
      def combined_page_status(page)
        page.status.delete_if { |s| s == :locked }.map do |state, true_value|
          classes = true_value ? "page_status #{state}" : "page_status not_#{state}"
          content_tag(:span, '', class: classes) + page.status_title(state)
        end.join("<br>").html_safe
      end

      # Renders a label for page's page layout
      #
      # If the page layout definition of the page is missing, it displays a warning.
      #
      def page_layout_label(page)
        if page.persisted? && page.definition.blank?
          [
            content_tag(:span, '',
              class: 'inline warning icon',
              title: Alchemy.t(:page_definition_missing)
            ),
            Alchemy.t(:page_type)
          ].join('&nbsp;').html_safe
        else
          Alchemy.t(:page_type)
        end
      end
    end
  end
end
