# frozen_string_literal: true

module Alchemy
  # The persisted version of a rendered picture variant
  #
  # You can configure the generator class to implement a
  # different thumbnail store (ie. a remote file storage).
  #
  #     config/initializers/alchemy.rb
  #     Alchemy::PictureThumb.generator_class = My::ThumbnailGenerator
  #
  class PictureThumb < BaseRecord
    belongs_to :picture, class_name: "Alchemy::Picture"

    validates :signature, presence: true
    validates :uid, presence: true

    class << self
      # Thumbnail generator class
      #
      # @see Alchemy::PictureThumb::Create
      def generator_class
        @_generator_class ||= Alchemy::PictureThumb::Create
      end

      # Set a thumbnail generator class
      #
      # @see Alchemy::PictureThumb::Create
      def generator_class=(klass)
        @_generator_class = klass
      end

      # Upfront generation of picture thumbnails
      #
      # Called after a Alchemy::Picture has been created (after an image has been uploaded)
      #
      # Generates three types of thumbnails that are used by Alchemys picture archive and
      # persists them in the configures file store (Default Dragonfly::FileDataStore).
      #
      # @see Picture::THUMBNAIL_SIZES
      def generate_thumbs!(picture)
        Alchemy::Picture::THUMBNAIL_SIZES.values.each do |size|
          variant = Alchemy::PictureVariant.new(picture, {
            size: size,
            flatten: true,
          })
          signature = Alchemy::PictureThumb::Signature.call(variant)
          thumb = find_by(signature: signature)
          next if thumb

          uid = Alchemy::PictureThumb::Uid.call(signature, variant)
          generator_class.call(variant, signature, uid)
        end
      end
    end
  end
end
