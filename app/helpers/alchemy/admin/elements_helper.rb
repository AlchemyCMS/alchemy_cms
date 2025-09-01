# frozen_string_literal: true

module Alchemy
  module Admin
    module ElementsHelper
      include Alchemy::Admin::IngredientsHelper

      # Returns an elements array for select helper.
      #
      # @param [Array] elements definitions
      # @return [Array<Hash>]
      #
      def elements_for_select(elements)
        return [] if elements.nil?

        elements.sort_by(&:name).map do |element|
          {
            text: Element.display_name_for(element.name),
            icon: element.icon_file,
            id: element.name
          }
        end
      end
    end
  end
end
