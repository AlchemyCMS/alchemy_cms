require "activestorage"

module Alchemy
  class StorageAdapter
    module ActiveStorage
      module PictureClassMethods
        def self.included(base)
          base.has_one_attached :image_file do |attachable|
            # Only works in Rails 7.1
            preprocessor_class.new(attachable).call
            preprocessor_class.generate_thumbs!(attachable)
          end
        end
      end

      extend self

      def preprocessor_class
        Alchemy::Picture::ActiveStoragePreprocessor
      end

      def url_class
        Alchemy::Picture::ActiveStorageUrl
      end

      def picture_file_formats
        ::ActiveStorage::Blob.joins(:attachments).merge(
          ::ActiveStorage::Attachment.where(record_type: "Alchemy::Picture")
        ).distinct.pluck(:content_type)
      end

      def rescuable_errors
        ::ActiveStorage::Error
      end

      def has_convertible_format?(picture)
        picture.image_file&.variable?
      end

      def image_file_name(picture)
        picture.image_file&.filename&.to_s
      end

      def image_file_format(picture)
        picture.image_file&.content_type
      end

      def image_file_size(picture)
        picture.image_file&.byte_size
      end

      def image_file_width(picture)
        picture.image_file&.metadata&.fetch(:width, nil)
      end

      def image_file_height(picture)
        picture.image_file&.metadata&.fetch(:height, nil)
      end

      def image_file_extension(picture)
        picture.image_file&.filename&.extension&.downcase
      end
    end
  end
end
