module Alchemy
  module Admin
    class AddElementButton < ViewComponent::Base
      erb_template <<~ERB
        <div class="add-element-button">
          <sl-tooltip content="<%= Alchemy.t("New Element") %>">
            <a
              href="<%= url %>"
              is="alchemy-dialog-link"
              class="icon_button"
              data-dialog-options='<%= dialog_options.to_json %>'
            >
              <alchemy-icon name="add" size="sm"></alchemy-icon>
            </a>
          </sl-tooltip>
        </div>
      ERB

      delegate :alchemy, :link_to_dialog, to: :helpers

      attr_reader :page_version_id, :after_element_id, :parent_element_id

      def initialize(page_version:, after_element: nil, parent_element: nil)
        @page_version_id = page_version.id
        @after_element_id = after_element&.id
        @parent_element_id = parent_element&.id
      end

      private

      def url
        alchemy.new_admin_element_path(
          parent_element_id:,
          page_version_id:,
          after_element_id:
        )
      end

      def dialog_options
        {
          size: "380x125",
          title: Alchemy.t("New Element")
        }
      end
    end
  end
end
