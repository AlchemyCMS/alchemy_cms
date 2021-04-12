# frozen_string_literal: true

module Alchemy
  module Admin
    module ElementsHelper
      include Alchemy::Admin::IngredientsHelper
      include Alchemy::Admin::ContentsHelper
      include Alchemy::Admin::EssencesHelper

      # Returns an elements array for select helper.
      #
      # @param [Array] elements definitions
      # @return [Array]
      #
      def elements_for_select(elements)
        return [] if elements.nil?

        elements.collect do |e|
          [
            Element.display_name_for(e["name"]),
            e["name"],
          ]
        end
      end
    end
  end
end
