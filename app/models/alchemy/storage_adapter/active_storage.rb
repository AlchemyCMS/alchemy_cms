module Alchemy
  class StorageAdapter
    module ActiveStorage
      module PictureClassMethods
        def self.included(base)
          base.has_one_attached :image_file do |attachable|
            # Only works in Rails 7.1+
            # https://github.com/rails/rails/pull/47473
            Alchemy.storage_adapter.preprocessor_class.new(attachable).call
            Alchemy.storage_adapter.preprocessor_class.generate_thumbs!(attachable)
          end

          base.after_create_commit if: :svg? do
            SanitizeSvgJob.perform_later(self, file_accessor: :image_file)
          end
        end
      end

      module AttachmentClassMethods
        def self.included(base)
          base.has_one_attached :file
          base.after_create_commit if: :svg? do
            SanitizeSvgJob.perform_later(self, file_accessor: :file)
          end
        end
      end

      extend self

      def attachment_url_class
        AttachmentUrl
      end

      def preprocessor_class
        Preprocessor
      end

      def picture_url_class
        PictureUrl
      end

      def file_formats(class_name, scope:)
        attachment_scope = case class_name
        when "Alchemy::Attachment" then scope.with_attached_file
        when "Alchemy::Picture" then scope.with_attached_image_file
        end

        attachment_scope.pluck("active_storage_blobs.content_type").uniq.tap(&:compact!).presence || []
      end

      # @param [String]
      # @return [Array<String>]
      def searchable_alchemy_resource_attributes(class_name)
        case class_name
        when "Alchemy::Attachment"
          %w[name file_blob_filename]
        when "Alchemy::Picture"
          %w[name image_file_blob_filename]
        end
      end

      # @param [String]
      # @return [Array<String>]
      def ransackable_attributes(_class_name)
        %w[name]
      end

      # @param [String]
      # @return [Array<String>]
      def ransackable_associations(class_name)
        case class_name
        when "Alchemy::Attachment"
          %w[file_blob]
        when "Alchemy::Picture"
          %w[image_file_blob]
        end
      end

      def rescuable_errors
        ::ActiveStorage::Error
      end

      # @param [String, Array<String>]
      # @return [Alchemy::Picture::ActiveRecord_Relation]
      def by_file_format_scope(file_format)
        Picture.with_attached_image_file.joins(:image_file_blob).where(active_storage_blobs: {content_type: file_format})
      end

      # @param [String, Array<String>]
      # @return [Alchemy::Atachment::ActiveRecord_Relation]
      def by_file_type_scope(file_type)
        Attachment.with_attached_file.joins(:file_blob).where(active_storage_blobs: {content_type: file_type})
      end

      # @param [String, Array<String>]
      # @return [Alchemy::Atachment::ActiveRecord_Relation]
      def not_file_type_scope(file_type)
        Attachment.with_attached_file.joins(:file_blob).where.not(active_storage_blobs: {content_type: file_type})
      end

      # @param [Alchemy::Attachment]
      # @return [String]
      def file_name(attachment)
        attachment.file&.filename&.to_s
      end

      # @param [Alchemy::Attachment]
      # @return [Integer]
      def file_size(attachment)
        attachment.file&.byte_size
      end

      # @param [Alchemy::Attachment]
      # @return [String]
      def file_mime_type(attachment)
        attachment.file&.content_type
      end

      # @param [Alchemy::Attachment]
      # @return [String]
      def file_extension(attachment)
        attachment.file&.filename&.extension
      end

      # @param [Alchemy::Picture]
      # @return [TrueClass, FalseClass]
      def has_convertible_format?(picture)
        picture.image_file&.variable?
      end

      # @param [Alchemy::Picture]
      # @return [String]
      def image_file_name(picture)
        picture.image_file&.filename&.to_s
      end

      # @param [Alchemy::Picture]
      # @return [String]
      def image_file_format(picture)
        picture.image_file&.content_type
      end

      # @param [Alchemy::Picture]
      # @return [Integer]
      def image_file_size(picture)
        picture.image_file&.byte_size
      end

      # @param [Alchemy::Picture]
      # @return [Integer]
      def image_file_width(picture)
        picture.image_file&.metadata&.fetch(:width, nil)
      end

      # @param [Alchemy::Picture]
      # @return [Integer]
      def image_file_height(picture)
        picture.image_file&.metadata&.fetch(:height, nil)
      end

      # @param [Alchemy::Picture]
      # @return [Integer]
      def image_file_extension(picture)
        picture.image_file&.filename&.extension&.downcase
      end

      # @param [Alchemy::Picture]
      # @return [TrueClass, FalseClass]
      def image_file_present?(picture)
        picture.image_file.attached?
      end

      # @param Alchemy::Picture::ActiveRecord_Relation
      # @return Alchemy::Picture::ActiveRecord_Relation
      def preloaded_pictures(pictures)
        pictures.with_attached_image_file
      end

      # @param [Alchemy::Attachment]
      # @return [TrueClass, FalseClass]
      def set_attachment_name?(attachment)
        attachment.file.changed?
      end
    end
  end
end
