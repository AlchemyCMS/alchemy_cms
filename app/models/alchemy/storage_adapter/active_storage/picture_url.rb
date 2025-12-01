# frozen_string_literal: true

module Alchemy
  class StorageAdapter
    # Returns the URL to a variant of a picture using ActiveStorage
    class ActiveStorage::PictureUrl
      attr_reader :picture, :image_file

      # @param [Alchemy::Picture]
      #
      def initialize(picture)
        @picture = picture
        @image_file = picture.image_file
      end

      # The URL to a variant of a picture
      #
      # @return [String]
      #
      def call(options = {})
        return nil unless image_file

        filename = image_filename(options)
        format = output_format(options)
        variant = image_variant(options.merge(format:))

        if variant
          Rails.application.routes.url_helpers.rails_blob_path(
            variant,
            {
              filename:,
              format:,
              only_path: true
            }
          )
        end
      end

      private

      def image_filename(options = {})
        if picture.name.presence
          picture.name.to_param
        else
          picture.image_file_name
        end
      end

      def output_format(options = {})
        if image_file.variable?
          options[:format] || default_output_format
        else
          picture.image_file_extension
        end
      end

      def image_variant(options = {})
        if image_file.variable?
          variant_options = DragonflyToImageProcessing.call(options)
          image_file.variant(variant_options)
        else
          image_file.blob
        end
      end

      def default_output_format
        if Alchemy.config.image_output_format == "original"
          picture.image_file_extension
        else
          Alchemy.config.image_output_format
        end
      end
    end
  end
end
