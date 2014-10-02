module Alchemy
  class API::ContentsController < BaseController
    respond_to :json

    load_and_authorize_resource
    layout false

    rescue_from CanCan::AccessDenied do |exception|
      raise ActiveRecord::RecordNotFound
    end


    def show
      render_with_protection @content
    end

  end
end
