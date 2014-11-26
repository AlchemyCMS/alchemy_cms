module Alchemy
  class ContentsController < BaseController
    load_and_authorize_resource
    layout false

    rescue_from CanCan::AccessDenied do |exception|
      raise ActiveRecord::RecordNotFound
    end

    def show
      ActiveSupport::Deprecation.warn('The Alchemy contents json API moved to `api` namespace. Please use `/api/contents` for json requests instead.')
      respond_to do |format|
        format.json { render json: @content }
      end
    end

  end
end
