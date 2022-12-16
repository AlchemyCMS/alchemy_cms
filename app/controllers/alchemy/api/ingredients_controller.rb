# frozen_string_literal: true

module Alchemy
  class Api::IngredientsController < Api::BaseController
    # Returns all ingredients as json object
    #
    # You can either load all or only these for :element_id or :page_id param
    #
    def index
      @ingredients = Alchemy::Ingredient.accessible_by(current_ability, :index)

      if params[:page_id].present?
        @ingredients = @ingredients
          .where(alchemy_page_versions: { page_id: params[:page_id] })
          .merge(Alchemy::PageVersion.drafts)
          .joins(element: :page_version)
      end

      render json: @ingredients, adapter: :json, root: "ingredients"
    end
  end
end
