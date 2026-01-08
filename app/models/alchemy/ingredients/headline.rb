# frozen_string_literal: true

module Alchemy
  module Ingredients
    # A text headline
    #
    class Headline < Alchemy::Ingredient
      include DomIds

      store_accessor :data,
        :dom_id,
        :level,
        :size

      allow_settings %i[
        anchor
        levels
        sizes
      ]

      before_create :set_level_and_size

      def preview_text(maxlength = 30)
        "H#{level}: #{value}"[0..maxlength - 1]
      end

      def levels
        settings.fetch(:levels, 1..6)
      end

      def sizes
        settings.fetch(:sizes, [])
      end

      private

      def set_level_and_size
        self.level ||= levels.first
        self.size ||= sizes.first
      end
    end
  end
end
