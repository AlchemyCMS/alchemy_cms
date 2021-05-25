# frozen_string_literal: true

module Alchemy
  module Admin
    class IngredientsController < Alchemy::Admin::BaseController
      load_and_authorize_resource class: Alchemy::Ingredient

      helper "Alchemy::Admin::Ingredients"

      def edit
      end

      def update
        @ingredient.update(ingredient_params)
      end

      private

      def ingredient_params
        params.require(:ingredient).permit(@ingredient.class.ingredient_attributes)
      end
    end
  end
end
