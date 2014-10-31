module Alchemy
  class ContentsController < BaseController
    load_and_authorize_resource
    layout false

    rescue_from CanCan::AccessDenied do |exception|
      raise ActiveRecord::RecordNotFound
    end

    def show
      respond_to do |format|
        format.json { render json: @content }
      end
    end

  end
end
