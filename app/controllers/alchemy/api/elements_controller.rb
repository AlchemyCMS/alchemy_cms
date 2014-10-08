module Alchemy
  class API::ElementsController < API::BaseController

    def show
      @element = Element.find(params[:id])
      authorize! :show, @element
      respond_with @element
    end
  end
end
