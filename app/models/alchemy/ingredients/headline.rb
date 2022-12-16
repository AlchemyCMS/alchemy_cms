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

      before_create :set_level_and_size

      def preview_text(maxlength = 30)
        "H#{level}: #{value}"[0..maxlength - 1]
      end

      def level_options
        levels.map { |level| ["H#{level}", level] }
      end

      def size_options
        sizes.map { |size| [".h#{size}", size] }
      end

      private

      def levels
        settings.fetch(:levels, (1..6))
      end

      def sizes
        settings.fetch(:sizes, [])
      end

      def set_level_and_size
        self.level ||= levels.first
        self.size ||= sizes.first
      end
    end
  end
end
