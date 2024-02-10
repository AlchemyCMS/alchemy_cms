# frozen_string_literal: true

require "alchemy/shell"
require "benchmark"
require "active_storage/service/disk_service"

module Alchemy
  class Upgrader::SevenPointOne < Upgrader
    extend Alchemy::Shell
    DEFAULT_CONTENT_TYPE = "application/octet-stream"
    DISK_SERVICE = ActiveStorage::Service::DiskService
    SERVICE_NAME = :alchemy_cms

    # Prevents (down)loading the original file
    METADATA = {
      identified: true, # Skip identifying file type
      analyzed: true, # Skip analyze job
      composed: true # Skip checksum check
    }

    class << self
      def migrate_pictures_to_active_storage
        pictures_without_as_attachment = Alchemy::Picture.where.missing(:image_file_attachment)
        count = pictures_without_as_attachment.count
        if count > 0
          log "Migrating #{count} Dragonfly image file(s) to ActiveStorage."
          realtime = Benchmark.realtime do
            pictures_without_as_attachment.find_each do |picture|
              Alchemy::Deprecation.silence do
                uid = picture.legacy_image_file_uid
                key = key_for_uid(uid)
                content_type = Mime::Type.lookup_by_extension(picture.legacy_image_file_format) || DEFAULT_CONTENT_TYPE
                Alchemy::Picture.transaction do
                  blob = ActiveStorage::Blob.create!(
                    key: key,
                    filename: picture.legacy_image_file_name,
                    byte_size: picture.legacy_image_file_size,
                    content_type: content_type,
                    metadata: METADATA.merge(
                      width: picture.legacy_image_file_width,
                      height: picture.legacy_image_file_height
                    ),
                    service_name: SERVICE_NAME
                  )
                  picture.create_image_file_attachment!(
                    name: :image_file,
                    record: picture,
                    blob: blob
                  )
                end
                move_file(Rails.root.join("uploads/pictures", uid), key)
              end
              print "."
            end
          end
          puts "\nDone in #{realtime.round(2)}s!"
        else
          log "No Dragonfly image files for migration found.", :skip
        end
      end

      def migrate_attachments_to_active_storage
        attachments_without_as_attachment = Alchemy::Attachment.where.missing(:file_attachment)
        count = attachments_without_as_attachment.count
        if count > 0
          log "Migrating #{count} Dragonfly attachment file(s) to ActiveStorage."
          realtime = Benchmark.realtime do
            attachments_without_as_attachment.find_each do |attachment|
              Alchemy::Deprecation.silence do
                uid = attachment.legacy_file_uid
                key = key_for_uid(uid)
                Alchemy::Attachment.transaction do
                  blob = ActiveStorage::Blob.create!(
                    key: key,
                    filename: attachment.legacy_file_name,
                    byte_size: attachment.legacy_file_size,
                    content_type: attachment.file_mime_type.presence || DEFAULT_CONTENT_TYPE,
                    metadata: METADATA,
                    service_name: SERVICE_NAME
                  )
                  attachment.create_file_attachment!(
                    record: attachment,
                    name: :file,
                    blob: blob
                  )
                end
                move_file(Rails.root.join("uploads/attachments", uid), key)
              end
              print "."
            end
          end
          puts "\nDone in #{realtime.round(2)}s!"
        else
          log "No Dragonfly attachment files for migration found.", :skip
        end
      end

      private

      # ActiveStorage::Service::DiskService stores files in a folder structure
      # based on the first two characters of the file uid.
      def key_for_uid(uid)
        case service
        when DISK_SERVICE
          uid.split("/").last
        else
          uid
        end
      end

      # ActiveStorage::Service::DiskService stores files in a folder structure
      # based on the first two characters of the file uid.
      def move_file(uid, key)
        case service
        when DISK_SERVICE
          if File.exist?(uid)
            service.send(:make_path_for, key)
            FileUtils.mv uid, service.send(:path_for, key)
          end
        end
      end

      def service
        ActiveStorage::Blob.services.fetch(SERVICE_NAME)
      end
    end
  end
end
