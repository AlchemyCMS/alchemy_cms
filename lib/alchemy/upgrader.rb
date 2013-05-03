module Alchemy
  class Upgrader < Alchemy::Seeder
    class << self

      # Runs ugrades
      #
      # Set UPGRADE env variable to only run a specific task.
      def run!
        if ENV['UPGRADE']
          ENV['UPGRADE'].split(',').each do |task|
            self.send(task)
          end
        else
          run_all
        end
        display_todos
      end

      def run_all
        Rake::Task['alchemy:install:migrations'].invoke
        Rake::Task['db:migrate'].invoke
        Seeder.seed!
        convert_attachment_storage
        copy_new_config_file
      end

    private

      def convert_attachment_storage
        desc "Convert the attachment storage"
        converted_files = []
        files = Dir.glob Rails.root.join 'uploads/attachments/**/*.*'
        if files.blank?
          log "No attachments found", :skip
        else
          files.each do |file|
            file_uid = file.gsub(/#{Rails.root.to_s}\/uploads\/attachments\//, '')
            file_id = file_uid.split('/')[1].to_i
            attachment = Alchemy::Attachment.find_by_id(file_id)
            if attachment && attachment.file_uid.blank?
              attachment.file_uid = file_uid
              attachment.file_size = File.new(file).size
              if attachment.save!
                log "Converted #{file_uid}"
              end
            else
              log "Attachment with id #{file_id} not found or already converted.", :skip
            end
          end
        end
      end

      def copy_new_config_file
        desc "Copy configuration file."
        config_file = Rails.root.join('config/alchemy/config.yml')
        default_config = File.join(File.dirname(__FILE__), '../../config/alchemy/config.yml')
        if FileUtils.identical? default_config, config_file
          log "Configuration file already present.", :skip
        else
          log "Custom configuration file found."
          FileUtils.cp default_config, Rails.root.join('config/alchemy/config.yml.defaults')
          log "Copied new default configuration file."
          todo "Check the default configuration file (./config/alchemy/config.yml.defaults) for new configuration options and insert them into your config file."
        end
      end

    end
  end
end
