# frozen_string_literal: true

module Alchemy
  module Admin
    module LinkDialog
      class FileTab < BaseTab
        delegate :alchemy, to: :helpers

        def title
          Alchemy.t("link_overlay_tab_label.file")
        end

        def name
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

        def attachments
          @_attachments ||= Attachment.all.collect { |f|
            [f.name, alchemy.download_attachment_path(id: f.id, name: f.slug)]
          }
        end

        def attachment_select
          label = label_tag("file_link", Alchemy.t(:file), class: "control-label")
          select = select_tag "file_link",
            options_for_select(attachments),
            prompt: Alchemy.t("Please choose"),
            is: "alchemy-select"
          content_tag("div", label + select, class: "input select")
        end
      end
    end
  end
end
