# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class FileTab < BaseTab
        delegate :alchemy, to: :helpers

        def title
          Alchemy.t("link_overlay_tab_label.file")
        end

        def self.panel_name
          :file
        end

        def fields
          [
            attachment_select,
            title_input,
            target_select
          ]
        end

        def message
          render_message(:info, content_tag("h3", Alchemy.t(:choose_file_to_link)))
        end

        private

        def attachment
          id = url&.match(/attachment\/(?<id>\d+)\/download/)&.captures
          @_attachment ||= Alchemy::Attachment.find_by(id: id)
        end

        def attachment_select
          label = label_tag("file_link", Alchemy.t(:file), class: "control-label")
          input = text_field_tag("file_link", attachment && url, id: "file_link")
          select = render Alchemy::Admin::AttachmentSelect.new(attachment).with_content(input)
          content_tag("div", label + select, class: "input select")
        end
      end
    end
  end
end
