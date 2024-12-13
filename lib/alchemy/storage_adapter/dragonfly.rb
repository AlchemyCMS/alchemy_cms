require "dragonfly"

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
                  Alchemy::Picture.preprocessor_class.new(image).call
                end
              end
            end
          end
        end
      end

      extend self

      CONVERTIBLE_FILE_FORMATS = %w[gif jpg jpeg png webp].freeze

      def preprocessor_class
        Alchemy::Picture::Preprocessor
      end

      def url_class
        Alchemy::Picture::Url
      end

      def picture_file_formats
        @_file_formats ||= Alchemy::Picture
          .distinct
          .pluck(:image_file_format)
          .compact
          .presence || []
      end

      def rescuable_errors
        ::Dragonfly::Job::Fetch::NotFound
      end

      def has_convertible_format?(picture)
        picture.image_file_format.in?(CONVERTIBLE_FILE_FORMATS)
      end

      def image_file_name(picture)
        picture.read_attribute(:image_file_name)
      end

      def image_file_format(picture)
        picture.image_file.mime_type
      end

      def image_file_size(picture)
        picture.read_attribute(:image_file_size)
      end

      def image_file_width(picture)
        picture.read_attribute(:image_file_width)
      end

      def image_file_height(picture)
        picture.read_attribute(:image_file_height)
      end

      def image_file_extension(picture)
        picture.read_attribute(:image_file_format)
      end
    end
  end
end
