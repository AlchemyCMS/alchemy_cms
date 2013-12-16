module Alchemy
  class ContentsController < BaseController
    load_and_authorize_resource
    layout false

    rescue_from CanCan::AccessDenied do |exception|
      raise ActiveRecord::RecordNotFound
    end

    respond_to :json

    def show
      respond_with @content
    end

  end
end
