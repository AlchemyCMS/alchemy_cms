# frozen_string_literal: true

module Alchemy
  class Element < BaseRecord
    module ElementEssences
      # Returns the contents essence value (aka. ingredient) for passed content name.
      def ingredient(name)
        content = content_by_name(name)
        return nil if content.blank?

        content.ingredient
      end

      # True if the element has a content for given name,
      # that has an essence value (aka. ingredient) that is not blank.
      def has_ingredient?(name)
        ingredient(name).present?
      end
    end
  end
end
