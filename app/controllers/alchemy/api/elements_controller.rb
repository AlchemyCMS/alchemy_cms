# frozen_string_literal: true

module Alchemy
  class Api::ElementsController < Api::BaseController
    # Returns all elements as json object
    #
    # You can either load all or only these for :page_id param
    #
    # If you want to only load a specific type of element pass ?named=an_element_name
    #
    def index
      @elements = Element.not_nested
      # Fix for cancancan not able to merge multiple AR scopes for logged in users
      if cannot? :manage, Alchemy::Element
        @elements = @elements.accessible_by(current_ability, :index)
      end
      if params[:page_id].present?
        @elements = @elements.where(page_id: params[:page_id])
      end
      if params[:named].present?
        @elements = @elements.named(params[:named])
      end
      @elements = @elements.includes(*element_includes)

      render json: @elements, adapter: :json, root: "elements"
    end

    # Returns a json object for element
    #
    def show
      @element = Element.where(id: params[:id]).includes(*element_includes).first
      authorize! :show, @element
      respond_with @element
    end

    private

    def element_includes
      [
        {
          nested_elements: [
            {
              contents: {
                essence: :ingredient_association,
              },
            },
            :tags,
          ],
        },
        {
          contents: {
            essence: :ingredient_association,
          },
        },
        :tags,
      ]
    end
  end
end
