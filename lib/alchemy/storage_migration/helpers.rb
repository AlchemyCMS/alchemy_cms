module Alchemy
  module StorageMigration
    class Helpers
      DEFAULT_CONTENT_TYPE = "application/octet-stream"
      DISK_SERVICE = "ActiveStorage::Service::DiskService"
      S3_SERVICE = "ActiveStorage::Service::S3Service"

      METADATA = {
        identified: true, # Skip identifying file type
        analyzed: true, # Skip analyze job
        composed: true # Skip checksum check
      }

      attr_reader :service

      def initialize(service_name)
        @service = ActiveStorage::Blob.services.fetch(service_name).to_s
      end

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

      def copy_file(uid, key)
        case service
        when DISK_SERVICE
          if File.exist?(uid)
            service.send(:make_path_for, key)
            FileUtils.cp uid, service.send(:path_for, key)
          end
        when S3_SERVICE
          if Aws::S3::Client.exist?(uid)
            service.send(:make_path_for, key)
            Aws::S3::Client.cp uid, service.send(:path_for, key)
          end
        end
      end
    end
  end
end
