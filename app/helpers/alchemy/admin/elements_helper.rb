# frozen_string_literal: true

module Alchemy
  module Admin
    module ElementsHelper
      include Alchemy::Admin::IngredientsHelper

      # Returns an elements array for select helper.
      #
      # @param [Array] elements definitions
      # @return [Array]
      #
      def elements_for_select(elements)
        return [] if elements.nil?

        elements.map do |e|
          [
            Element.display_name_for(e.name),
            e.name
          ]
        end.tap(&:sort!)
      end
    end
  end
end
