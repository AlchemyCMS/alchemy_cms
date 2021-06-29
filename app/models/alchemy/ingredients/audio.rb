# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A audio attachment
    #
    class Audio < Alchemy::Ingredient
      store_accessor :data,
        :autoplay,
        :controls,
        :muted,
        :loop

      related_object_alias :attachment, class_name: "Alchemy::Attachment"

      delegate :name, to: :attachment, allow_nil: true

      # The first 30 characters of the attachments name
      #
      # Used by the Element#preview_text method.
      #
      # @param [Integer] max_length (30)
      #
      def preview_text(max_length = 30)
        name.to_s[0..max_length - 1]
      end
    end
  end
end
