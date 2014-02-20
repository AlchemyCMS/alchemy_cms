module Alchemy
  module Admin
    module ContentsHelper
      include Alchemy::Admin::BaseHelper

      # Renders the name of elements content.
      #
      # Displays a warning icon if content is missing its description.
      #
      # Displays a mandatory field indicator, if the content has validations.
      #
      def render_content_name(content)
        if content.blank?
          warning('Content is nil')
          return
        else
          content_name = content.name_for_label
        end
        if content.description.blank?
          warning("Content #{content.name} is missing its description")
          title = _t(:content_description_missing)
          content_name = %(<span class="warning icon" title="#{title}"></span>&nbsp;#{content_name}).html_safe
        end
        if content.has_validations?
          "#{content_name}<span class='validation_indicator'>*</span>".html_safe
        else
          content_name
        end
      end

      # Renders a link to show the new content overlay that lets you add additional contents.
      #
      # See +render_create_content_link+ helper for examples on how to define additional contents.
      #
      def render_new_content_link(element)
        link_to_dialog(
          "#{render_icon(:create)} #{_t('add new content')}".html_safe,
          alchemy.new_admin_element_content_path(element),
          {
            size: '310x115',
            title: _t('Select an content'),
            overflow: true
          },
          {
            id: "add_content_for_element_#{element.id}",
            class: 'button with_icon new_content_link'
          }
        )
      end

      # Renders a link that dynamically adds an additional content into your element editor view.
      #
      # NOTE: You have to define additional contents in your elements.yml file first.
      #
      # ==== Example:
      #
      #   # config/alchemy/elements.yml
      #   - name: downloads:
      #     contents:
      #     - name: file
      #       type: EssenceFile
      #     additional_contents:
      #     - name: file
      #       type: EssenceFile
      #
      # Then add this helper into the elements editor view partial:
      #
      #   <%= render_create_content_link(element, 'file') %>
      #
      # Optionally you can pass a label:
      #
      #   <%= render_create_content_link(element, 'file', label: 'Add a file') %>
      #
      def render_create_content_link(element, content_name, options = {}, options_for_content = {})
        defaults = {
          label: _t('Add %{name}', name: _t(content_name, scope: :content_names))
        }
        options = defaults.merge(options)
        link_to(render_icon(:create) + options[:label], alchemy.admin_contents_path(
            content: {
              name: content_name,
              element_id: element.id
            },
            options: options_for_content.to_json
          ),
          method: :post,
          remote: true,
          id: "add_content_for_element_#{element.id}",
          class: 'button with_icon new_content_link'
        )
      end

      # Renders a link for removing that content
      def delete_content_link(content)
        link_to_confirm_dialog(
          render_icon('delete-small'),
          _t('Do you really want to delete this content?'),
          alchemy.admin_content_path(content),
          class: 'icon_button small',
          title: _t('Remove this content')
        ) if content.settings[:deletable]
      end

      # Renders the label and a remove link for a content.
      def label_and_remove_link(content)
        content_tag :label do
          [render_hint_for(content), render_content_name(content), delete_content_link(content)].compact.join('&nbsp;').html_safe
        end
      end

    end
  end
end
