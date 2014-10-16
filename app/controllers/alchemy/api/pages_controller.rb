module Alchemy
  class API::PagesController < API::BaseController

    before_action :load_page

    def show
      authorize! :show, @page
      respond_with @page
    end

    private

    def load_page
      @page = Page.find_by(id: params[:id]) ||
              Page.find_by(urlname: params[:urlname]) ||
              raise(ActiveRecord::RecordNotFound)
    end
  end
end
