module Alchemy
  class Api::PagesController < Api::BaseController
    before_action :load_page, only: [:show]

    # Returns all pages as json object
    #
    def index
      @pages = Page.accessible_by(current_ability, :index)
      if params[:page_layout].present?
        @pages = @pages.where(page_layout: params[:page_layout])
      end
      respond_with @pages
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
