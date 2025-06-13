# frozen_string_literal: true

require "alchemy/storage_migration/helpers"

module Alchemy
  module StorageMigration
    class MigratePictureJob < BaseJob
      queue_as :default

      def perform(picture, service_name:)
        helpers = Alchemy::StorageMigration::Helpers.new(service_name)

        uid = picture.read_attribute(:image_file_uid)
        key = helpers.key_for_uid(uid)
        content_type = Mime::Type.lookup_by_extension(picture.image_file_format) || Alchemy::StorageMigration::Helpers::DEFAULT_CONTENT_TYPE
        Alchemy::Picture.transaction do
          blob = ActiveStorage::Blob.create!(
            key: key,
            filename: picture.image_file_name,
            byte_size: picture.image_file_size,
            content_type: content_type,
            # Prevents (down)loading the original file
            metadata: Alchemy::StorageMigration::Helpers::METADATA.merge(
              width: picture.image_file_width,
              height: picture.image_file_height
            ),
            service_name: service_name
          )
          picture.create_image_file_attachment!(
            name: :image_file,
            record: picture,
            blob: blob
          )
        end
        helpers.copy_file(Rails.root.join("uploads/pictures", uid), key)
      end
    end
  end
end
