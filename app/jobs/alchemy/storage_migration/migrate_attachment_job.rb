# frozen_string_literal: true

require "alchemy/storage_migration/helpers"

module Alchemy
  module StorageMigration
    class MigrateAttachmentJob < BaseJob
      queue_as :default

      def perform(attachment, service_name:)
        helpers = Alchemy::StorageMigration::Helpers.new(service_name)
        uid = attachment.legacy_file_uid
        key = helpers.key_for_uid(uid)
        Alchemy::Attachment.transaction do
          blob = ActiveStorage::Blob.create!(
            key: key,
            filename: attachment.legacy_file_name,
            byte_size: attachment.legacy_file_size,
            content_type: attachment.file_mime_type.presence || Alchemy::StorageMigration::Helpers::DEFAULT_CONTENT_TYPE,
            metadata: Alchemy::StorageMigration::Helpers::METADATA,
            service_name: service_name
          )
          attachment.create_file_attachment!(
            record: attachment,
            name: :file,
            blob: blob
          )
        end
        helpers.copy_file(Rails.root.join("uploads/attachments", uid), key)
      end
    end
  end
end
