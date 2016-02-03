module Alchemy
  module Admin
    module PagesHelper
      include Alchemy::BaseHelper

      # Used for rendering the folder link in +Admin::Pages#index+ sitemap.
      #
      def sitemap_folder_link(page)
        if page.folded?(current_alchemy_user.id)
          css_class = 'folded'
          title = _t('Show childpages')
        else
          css_class = 'collapsed'
          title = _t('Hide childpages')
        end
        link_to(
          '',
          alchemy.fold_admin_page_path(page),
          remote: true,
          method: :post,
          class: "page_folder #{css_class} spinner",
          title: title,
          id: "fold_button_#{page.id}"
        )
      end

      # Returns options tags for the screen sizes select in page edit view.
      #
      def preview_sizes_for_select
        options_for_select([
          'auto',
          [_t('240', :scope => 'preview_sizes'), 240],
          [_t('320', :scope => 'preview_sizes'), 320],
          [_t('480', :scope => 'preview_sizes'), 480],
          [_t('768', :scope => 'preview_sizes'), 768],
          [_t('1024', :scope => 'preview_sizes'), 1024],
          [_t('1280', :scope => 'preview_sizes'), 1280]
        ])
      end

      # Returns the translated explanation of the page´s status.
      #
      def combined_page_status(page)
        page.status.map do |state, value|
          next if state == :locked
          css_class = page.send("#{state}?") ? "page_status #{state}" : "page_status not_#{state}"
          val = content_tag(:span, '', class: css_class)
          val += page.status_title(state)
        end.delete_if(&:blank?).join("<br>").html_safe
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
              title: _t(:page_definition_missing)
            ),
            _t(:page_type)
          ].join('&nbsp;').html_safe
        else
          _t(:page_type)
        end
      end
    end
  end
end
