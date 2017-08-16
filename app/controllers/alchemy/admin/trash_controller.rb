# frozen_string_literal: true

module Alchemy
  module Admin
    class TrashController < Alchemy::Admin::BaseController
      helper "alchemy/admin/elements"

      authorize_resource class: false

      def index
        @elements = Element.trashed
        @page = Page.find(params[:page_id])
        @allowed_elements = @page.available_element_definitions
      end

      def clear
        @page = Page.find(params[:page_id])
        @elements = Element.trashed
        @elements.map(&:destroy)
      end
    end
  end
end
