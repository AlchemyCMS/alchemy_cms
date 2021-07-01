# frozen_string_literal: true

module Alchemy
  module Admin
    class IngredientsController < Alchemy::Admin::BaseController
      load_and_authorize_resource class: Alchemy::Ingredient

      include CropAction

      helper "Alchemy::Admin::Ingredients"

      def edit
      end

      def update
        @ingredient.update(ingredient_params)
      end

      private

      def ingredient_params
        params.require(:ingredient).permit(@ingredient.class.stored_attributes[:data])
      end

      def load_croppable_resource
        @croppable_resource = @ingredient
      end
    end
  end
end
