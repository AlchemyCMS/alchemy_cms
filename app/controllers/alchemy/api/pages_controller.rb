module Alchemy
  class Api::PagesController < Api::BaseController
    before_action :load_page, only: [:show]

    # Returns all pages as json object
    #
    def index
      @pages = Page.searchables
      if params[:page_layout].present?
        @pages = @pages.where(page_layout: params[:page_layout])
      elsif params[:q].present?
        @pages = @pages.where(["urlname like :q", q: "%#{params[:q]}%"])
      end
      page = [params[:page].to_i, 1].min
      respond_with @pages.page(page).per(25), meta: {total: @pages.count}
    end

    # Returns a json object for page
    #
    # You can either load the page via id or its urlname
    #
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
