module Alchemy
  class API::BaseController < Alchemy::BaseController
    layout false
    respond_to :json

    rescue_from CanCan::AccessDenied do |exception|
      render json: 'Not authorized', status: 403
    end
  end
end
