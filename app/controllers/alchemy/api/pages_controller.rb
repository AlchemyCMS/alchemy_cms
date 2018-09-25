# frozen_string_literal: true

module Alchemy
  class Api::PagesController < Api::BaseController
    before_action :load_page, only: [:show]

    # Returns all pages as json object
    #
    def index
      # Fix for cancancan not able to merge multiple AR scopes for logged in users
      if can? :edit_content, Alchemy::Page
        @pages = Page.all
      else
        @pages = Page.accessible_by(current_ability, :index)
      end
      if params[:page_layout].present?
        @pages = @pages.where(page_layout: params[:page_layout])
      end
      render json: @pages, adapter: :json, root: :pages
    end

    # Returns all pages as nested json object for tree views
    #
    # Pass a page_id param to only load tree for this page
    #
    # Pass elements=true param to include elements for pages
    #
    def nested
      @page = Page.find_by(id: params[:page_id]) || Language.current_root_page

      render json: PageTreeSerializer.new(@page,
        ability: current_ability,
        user: current_alchemy_user,
        elements: params[:elements],
        full: true)
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
              Language.current.pages.find_by(
                urlname: params[:urlname],
                language_code: params[:locale] || Language.current.code
              ) ||
              raise(ActiveRecord::RecordNotFound)
    end
  end
end
