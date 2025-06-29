module Alchemy
  class StorageAdapter
    module Dragonfly
      module PictureClassMethods
        def self.included(base)
          base.class_eval do
            dragonfly_accessor :image_file, app: :alchemy_pictures do
              # Preprocess after uploading the picture
              after_assign do |image|
                if has_convertible_format?
                  Alchemy.storage_adapter.preprocessor_class.new(image).call
                end
              end
            end

            has_many :thumbs, class_name: "Alchemy::PictureThumb", dependent: :destroy

            # Create important thumbnails upfront
            after_create -> { PictureThumb.generate_thumbs!(self) },
              if: :has_convertible_format?
          end
        end
      end

      module AttachmentClassMethods
        def self.included(base)
          base.class_eval do
            dragonfly_accessor :file, app: :alchemy_attachments do
              after_assign { |file|
                write_attribute(:file_mime_type, file.mime_type)
              }
            end
          end
        end
      end

      extend self

      CONVERTIBLE_FILE_FORMATS = %w[gif jpg jpeg png webp].freeze

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
        mime_type_column = case class_name
        when "Alchemy::Attachment" then :file_mime_type
        when "Alchemy::Picture" then :image_file_format
        end

        scope.reorder(mime_type_column).distinct.pluck(mime_type_column).compact.presence || []
      end

      # @param [String]
      # @return [Array<String>]
      def searchable_alchemy_resource_attributes(class_name)
        case class_name
        when "Alchemy::Attachment"
          %w[name file_name]
        when "Alchemy::Picture"
          %w[name image_file_name]
        end
      end
      alias_method :ransackable_attributes, :searchable_alchemy_resource_attributes

      # @param [String]
      # @return [Array<String>]
      def ransackable_associations(_class_name)
        %w[]
      end

      def rescuable_errors
        ::Dragonfly::Job::Fetch::NotFound
      end

      # @param [String]
      # @return [Alchemy::Picture::ActiveRecord_Relation]
      def by_file_format_scope(file_format)
        Picture.where(image_file_format: file_format)
      end

      # @param [String]
      # @return [Alchemy::Attachment::ActiveRecord_Relation]
      def by_file_type_scope(file_type)
        Attachment.where(file_mime_type: file_type)
      end

      # @param [Alchemy::Attachment]
      # @return [String]
      def file_name(attachment)
        attachment.read_attribute(:file_name)
      end

      # @param [Alchemy::Attachment]
      # @return [Integer]
      def file_size(attachment)
        attachment.read_attribute(:file_size)
      end

      # @param [Alchemy::Attachment]
      # @return [String]
      def file_mime_type(attachment)
        attachment.read_attribute(:file_mime_type)
      end

      # @param [Alchemy::Attachment]
      # @return [String]
      def file_extension(attachment)
        content_type = file_mime_type(attachment)
        MiniMime.lookup_by_content_type(content_type)&.extension if content_type
      end

      # @param [Alchemy::Picture]
      # @return [TrueClass, FalseClass]
      def has_convertible_format?(picture)
        image_file_extension(picture).in?(CONVERTIBLE_FILE_FORMATS)
      end

      # @param [Alchemy::Picture]
      # @return [String]
      def image_file_name(picture)
        picture.read_attribute(:image_file_name)
      end

      # @param [Alchemy::Picture]
      # @return [String]
      def image_file_format(picture)
        ext = picture.read_attribute(:image_file_format)
        MiniMime.lookup_by_extension(ext)&.content_type if ext
      end

      # @param [Alchemy::Picture]
      # @return [Integer]
      def image_file_size(picture)
        picture.read_attribute(:image_file_size)
      end

      # @param [Alchemy::Picture]
      # @return [Integer]
      def image_file_width(picture)
        picture.read_attribute(:image_file_width)
      end

      # @param [Alchemy::Picture]
      # @return [Integer]
      def image_file_height(picture)
        picture.read_attribute(:image_file_height)
      end

      # @param [Alchemy::Picture]
      # @return [String]
      def image_file_extension(picture)
        picture.read_attribute(:image_file_format)
      end

      # @param [Alchemy::Picture]
      # @return [TrueClass, FalseClass]
      def image_file_present?(picture)
        !!picture.image_file
      end

      # @param Alchemy::Picture::ActiveRecord_Relation
      # @return Alchemy::Picture::ActiveRecord_Relation
      def preloaded_pictures(pictures)
        pictures.includes(:thumbs)
      end

      # @param [Alchemy::Attachment]
      # @return [TrueClass, FalseClass]
      def set_attachment_name?(attachment)
        attachment.file_name_changed?
      end
    end
  end
end
