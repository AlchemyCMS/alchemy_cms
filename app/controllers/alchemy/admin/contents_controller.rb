# frozen_string_literal: true

module Alchemy
  module Admin
    class ContentsController < Alchemy::Admin::BaseController
      helper 'alchemy/admin/essences'

      authorize_resource class: Alchemy::Content

      def create
        @element = Element.find(params[:content][:element_id])
        @content = Content.create_from_scratch(@element, content_params)
        @html_options = params[:html_options] || {}
      end

      private

      def content_params
        params.require(:content).permit(:element_id, :name, :ingredient, :essence_type)
      end
    end
  end
end
