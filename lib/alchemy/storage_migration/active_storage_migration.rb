require "active_storage"
require "dragonfly"

module Alchemy
  module StorageMigration
    # == Alchemy::StorageMigration::ActiveStorageMigration
    #
    # This class provides methods to migrate files from Dragonfly storage to ActiveStorage
    # for Alchemy pictures and attachments.
    #
    # === Usage
    #
    #   Alchemy::StorageMigration::ActiveStorageMigration.start!(service_name: "amazon", async: true)
    #
    # === Class Methods
    #
    # - +start!(service_name:, async: true)+:: Starts the migration process for the given ActiveStorage service.
    #
    # === Instance Methods
    #
    # - +migrate_pictures(service_name:, async: true)+:: Migrates all Alchemy::Picture records without an ActiveStorage attachment.
    # - +migrate_attachments(service_name:, async: true)+:: Migrates all Alchemy::Attachment records without an ActiveStorage attachment.
    #
    # === Options
    #
    # - +service_name+:: The name of the ActiveStorage service to use for migration (e.g., "amazon", "local").
    # - +async+:: Whether to run the migration jobs asynchronously (default: true).
    #
    # === Example
    #
    #   migration = Alchemy::StorageMigration::ActiveStorageMigration.new
    #   migration.migrate_pictures(service_name: "amazon", async: false)
    #
    class ActiveStorageMigration
      attr_reader :service_name

      def self.start!(service_name:, async: true)
        new.tap do |task|
          task.migrate_pictures(service_name:, async:)
          task.migrate_attachments(service_name:, async:)
        end
      end

      def migrate_pictures(service_name:, async: true)
        Dragonfly.logger = Rails.logger
        Alchemy.storage_adapter = :dragonfly

        pictures_without_as_attachment = Alchemy::Picture.where.missing(:image_file_attachment)
        count = pictures_without_as_attachment.count
        if count.positive?
          log "Migrating #{count} Dragonfly image file(s) to ActiveStorage."
          if async
            pictures_without_as_attachment.find_each do |picture|
              MigratePictureJob.perform_later(picture, service_name:)
            end
            puts "\nAll background jobs scheduled!"
          else
            realtime = Benchmark.realtime do
              pictures_without_as_attachment.find_each do |picture|
                MigratePictureJob.perform_now(picture, service_name:)
                print "."
              end
            end
            puts "\nDone in #{realtime.round(2)}s!"
          end
        else
          log "No Dragonfly image files for migration found.", :skip
        end
      end

      def migrate_attachments(service_name:, async: true)
        Dragonfly.logger = Rails.logger
        Alchemy.storage_adapter = :dragonfly

        attachments_without_as_attachment = Alchemy::Attachment.where.missing(:file_attachment)
        count = attachments_without_as_attachment.count
        if count.positive?
          log "Migrating #{count} Dragonfly attachment file(s) to ActiveStorage."
          if async
            attachments_without_as_attachment.find_each do |attachment|
              MigrateAttachmentJob.perform_later(picture, service_name:)
            end
            puts "\nAll background jobs scheduled!"
          else
            realtime = Benchmark.realtime do
              attachments_without_as_attachment.find_each do |attachment|
                MigrateAttachmentJob.perform_now(picture, service_name:)
                print "."
              end
            end
            puts "\nDone in #{realtime.round(2)}s!"
          end
        else
          log "No Dragonfly attachment files for migration found.", :skip
        end
      end
    end
  end
end
