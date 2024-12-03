require "alchemy/shell"
require "alchemy/upgrader/tasks/active_storage_migration"
require "benchmark"
require "dragonfly"
require "fileutils"
require "thor"

module Alchemy
  class Upgrader::EightZero < Upgrader
    include Thor::Base
    include Thor::Actions

    class << self
      def install_active_storage
        Rake::Task["active_storage:install"].invoke
        Rake::Task["db:migrate"].invoke

        text = <<-YAML.strip_heredoc

          alchemy_cms:
            service: Disk
            root: <%= Rails.root.join("storage") %>
        YAML

        storage_yml = Rails.application.root.join("config/storage.yml")
        if File.exist?(storage_yml)
          task.insert_into_file(storage_yml, text)
        else
          task.create_file(storage_yml, text)
        end
      end

      def prepare_dragonfly_config
        task.prepend_to_file "config/initializers/dragonfly.rb", <<~RUBY
          require "dragonfly"
        RUBY
      end

      def migrate_pictures_to_active_storage
        Dragonfly.logger = Rails.logger

        Alchemy::Picture.class_eval do
          extend Dragonfly::Model
          dragonfly_accessor :legacy_image_file, app: :alchemy_pictures
        end

        pictures_without_as_attachment = Alchemy::Picture.where.missing(:image_file_attachment)
        count = pictures_without_as_attachment.count
        if count > 0
          log "Migrating #{count} Dragonfly image file(s) to ActiveStorage."
          realtime = Benchmark.realtime do
            pictures_without_as_attachment.find_each do |picture|
              Alchemy::Upgrader::Tasks::ActiveStorageMigration.migrate_picture(picture)
              print "."
            end
          end
          puts "\nDone in #{realtime.round(2)}s!"
        else
          log "No Dragonfly image files for migration found.", :skip
        end
      end

      def migrate_attachments_to_active_storage
        Dragonfly.logger = Rails.logger

        Alchemy::Attachment.class_eval do
          extend Dragonfly::Model
          dragonfly_accessor :legacy_file, app: :alchemy_attachments
        end

        attachments_without_as_attachment = Alchemy::Attachment.where.missing(:file_attachment)
        count = attachments_without_as_attachment.count
        if count > 0
          log "Migrating #{count} Dragonfly attachment file(s) to ActiveStorage."
          realtime = Benchmark.realtime do
            attachments_without_as_attachment.find_each do |attachment|
              Alchemy::Upgrader::Tasks::ActiveStorageMigration.migrate_attachment(attachment)
              print "."
            end
          end
          puts "\nDone in #{realtime.round(2)}s!"
        else
          log "No Dragonfly attachment files for migration found.", :skip
        end
      end

      def remove_dragonfly_todo
        todo <<-TXT.strip_heredoc
          Please check if all pictures and attachments are migrated to ActiveStorage.

          If so, you can remove the Dragonfly gem, its configuration and storage by running:

              rm config/initializers/dragonfly.rb
              rm -rf uploads

        TXT
      end

      private

      def task
        @_task || new
      end
    end
  end
end
