module Alchemy
  # Provides methods to secure your picture attributes against DOS attacks.
  #
  class PictureAttributes

    SECURE_ATTRIBUTES = %w(id size crop crop_from crop_size quality).freeze

    class << self

      # Secures given attributes
      #
      # @param attributes [Hash]
      # @return [String]
      #
      def secure(attributes)
        Digest::SHA1.hexdigest(joined_attributes(attributes))[0..15]
      end

      private

      # Takes attributes and joins them with the +security_token+ of your rails app.
      #
      def joined_attributes(attributes)
        attributes.stringify_keys.values_at(*SECURE_ATTRIBUTES, Rails.configuration.secret_token).join('-')
      end

    end
  end
end
