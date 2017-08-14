# frozen_string_literal: true

module Alchemy
  class ElementsController < Alchemy::BaseController
    load_and_authorize_resource
    layout false

    rescue_from CanCan::AccessDenied do
      raise ActiveRecord::RecordNotFound
    end

    # == Renders the element view partial
    #
    # === Accepted Formats
    #
    # * html
    # * js (Tries to replace a given +container_id+ with the elements view partial content via jQuery.)
    #
    def show
      @page = @element.page
      @options = params[:options]

      respond_to do |format|
        format.html
        format.js { @container_id = params[:container_id] }
      end
    end
  end
end
