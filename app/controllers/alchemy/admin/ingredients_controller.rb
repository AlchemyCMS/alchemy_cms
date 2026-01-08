# frozen_string_literal: true

module Alchemy
  module Admin
    class IngredientsController < Alchemy::Admin::BaseController
      load_and_authorize_resource class: Alchemy::Ingredient

      include CropAction

      helper "Alchemy::Admin::Ingredients"

      def edit
        @language = Alchemy::Language.find_by(id: params[:language_id]) ||
          Alchemy::Current.language
      end

      def update
        @page = @ingredient.page # necessary to a render picture ingredient component
        @ingredient.update(ingredient_params)
      end

      private

      def ingredient_params
        params[:ingredient]&.permit(@ingredient.class.stored_attributes[:data]) ||
          ActionController::Parameters.new
      end

      def load_croppable_resource
        @croppable_resource = @ingredient
      end
    end
  end
end
