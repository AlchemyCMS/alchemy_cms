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
      # Fix for cancancan not able to merge multiple AR scopes for logged in users
      if cannot? :manage, Alchemy::Element
        @elements = Alchemy::Element.accessible_by(current_ability, :index)
      else
        @elements = Alchemy::Element.all
      end

      @elements = @elements.not_nested.joins(:page_version).merge(PageVersion.published)

      if params[:page_id].present?
        @elements = @elements.includes(:page).where(alchemy_pages: { id: params[:page_id] })
      else
        @elements = @elements.includes(*element_includes)
      end

      if params[:named].present?
        @elements = @elements.named(params[:named])
      end
      @elements = @elements.order(:position)

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
              ingredients: :related_object,
            },
            :tags,
          ],
        },
        {
          ingredients: :related_object,
        },
        :tags,
      ]
    end
  end
end
