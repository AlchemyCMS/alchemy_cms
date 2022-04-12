# frozen_string_literal: true

module Alchemy
  class Picture < BaseRecord
    class Url
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
        variant_options = DragonflyToImageProcessing.call(options)
        variant = image_file&.variant(variant_options)
        return unless variant

        Rails.application.routes.url_helpers.rails_storage_proxy_url(
          variant,
          {
            filename: filename(options),
            only_path: true,
            format: nil
          }
        )
      end

      private

      def filename(options = {})
        format = options[:format] || picture.image_file_extension
        if picture.name.presence
          "#{picture.name.to_param}.#{format}"
        else
          picture.image_file_name
        end
      end
    end
  end
end
