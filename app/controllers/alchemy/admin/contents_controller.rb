# frozen_string_literal: true

module Alchemy
  module Admin
    class ContentsController < Alchemy::Admin::BaseController
      helper "alchemy/admin/essences"

      authorize_resource class: Alchemy::Content

      def create
        @content = Content.create(content_params)
      end

      private

      def content_params
        params.require(:content).permit(:element_id, :name, :ingredient)
      end
    end
  end
end
