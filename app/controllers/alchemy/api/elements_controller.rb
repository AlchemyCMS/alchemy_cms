module Alchemy
  class Api::ElementsController < Api::BaseController
    # Returns all elements as json object
    #
    # You can either load all or only these for :page_id param
    #
    # If you want to only load a specific type of element pass ?named=an_element_name
    #
    def index
      @elements = Element.accessible_by(current_ability, :index)
      if params[:page_id].present?
        @elements = @elements.joins(page: :public_version)
                      .where(alchemy_page_versions: {page_id: params[:page_id]})
      end
      if params[:named].present?
        @elements = @elements.named(params[:named])
      end
      respond_with @elements
    end

    # Returns a json object for element
    #
    def show
      @element = Element.find(params[:id])
      authorize! :show, @element
      respond_with @element
    end
  end
end
