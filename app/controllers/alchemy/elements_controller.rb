module Alchemy
  class ElementsController < Alchemy::BaseController
    load_and_authorize_resource
    layout false

    rescue_from CanCan::AccessDenied do |exception|
      raise ActiveRecord::RecordNotFound
    end

    # == Renders the element view partial
    #
    # === Accepted Formats
    #
    # * html
    # * js (Tries to replace a given +container_id+ with the elements view partial content via jQuery.)
    # * json (A JSON object that includes all contents and their ingredients)
    #
    def show
      @page = @element.page
      @options = params[:options]

      respond_to do |format|
        format.html
        format.js   { @container_id = params[:container_id] }
        format.json { render json: @element }
      end
    end

  end
end
