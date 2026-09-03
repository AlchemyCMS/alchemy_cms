# frozen_string_literal: true

module Alchemy
  module Configurations
    class Uploader < Alchemy::Configuration
      class AllowedFileTypes < Alchemy::Configuration
        # Document, media and archive formats Alchemy knows how to display.
        # Executables and other active content are deliberately absent.
        DEFAULT_ATTACHMENT_FILE_TYPES = %w[
          pdf
          doc docx odt rtf txt
          xls xlsx ods csv
          ppt pptx odp
          vcf
          zip
          avif gif jpeg jpg png psd svg tif tiff webp
          aac flac m4a mp3 oga ogg wav weba
          avi flv m4v mov mp4 mpeg mpg ogv webm wmv
        ].freeze

        option :alchemy_attachments, :collection, item_type: :string, default: DEFAULT_ATTACHMENT_FILE_TYPES
        option :alchemy_pictures, :collection, item_type: :string, default: %w[jpg jpeg gif png svg webp]

        def set(configuration_hash)
          super(configuration_hash.transform_keys { transform_key(_1) })
        end

        def get(key)
          super(transform_key(key))
        end
        alias_method :[], :get

        private

        def transform_key(key)
          key.to_s.tr("/", "_")
        end
      end

      # Number of files that can be uploaded at once
      option :upload_limit, :integer, default: 50
      # Megabytes
      option :file_size_limit, :integer, default: 100

      configuration :allowed_filetypes, AllowedFileTypes
    end
  end
end
