# frozen_string_literal: true

module Alchemy
  class Api::BaseController < Alchemy::BaseController
    layout false
    respond_to :json

    rescue_from CanCan::AccessDenied,         with: :render_not_authorized
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    private

    def render_not_authorized
      render json: {error: 'Not authorized'}, status: 403
    end

    def render_not_found
      render json: {error: 'Record not found'}, status: 404
    end
  end
end
