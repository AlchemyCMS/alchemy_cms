# frozen_string_literal: true

module Alchemy
  class Picture < BaseRecord
    class Url
      attr_reader :variant

      # @param [Alchemy::PictureVariant]
      #
      def initialize(variant)
        raise ArgumentError, "Variant missing!" if variant.nil?

        @variant = variant
      end

      # The URL to a variant of a picture
      #
      # @param [Hash] params URL params
      #
      # @return [String]
      #
      def call(params = {})
        variant.url(params)
      end
    end
  end
end
