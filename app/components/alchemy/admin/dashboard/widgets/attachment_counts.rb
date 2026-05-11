module Alchemy
  module Admin
    module Dashboard
      module Widgets
        class AttachmentCounts < StatWidget
          private

          def title = Alchemy::Attachment.model_name.human(count: :many)
          def link = alchemy.admin_attachments_path
          def icon = "file-copy-2"
          def count = Alchemy::Attachment.count
          def infos = number_to_human_size(Alchemy::Attachment.sum(&:file_size))
        end
      end
    end
  end
end
