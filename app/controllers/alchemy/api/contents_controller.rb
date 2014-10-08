module Alchemy
  class API::ContentsController < API::BaseController

    def show
      @content = Content.find(params[:id])
      authorize! :show, @content
      respond_with @content
    end
  end
end
