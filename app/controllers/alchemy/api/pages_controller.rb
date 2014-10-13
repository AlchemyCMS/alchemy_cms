module Alchemy
  class API::PagesController < API::BaseController

    def show
      @page = Page.find_by!(urlname: params[:urlname])
      authorize! :show, @page
      respond_with @page
    end
  end
end
