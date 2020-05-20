# frozen_string_literal: true

module Alchemy
  module Admin
    class TrashController < Alchemy::Admin::BaseController
      helper "alchemy/admin/elements"

      authorize_resource class: false

      def index
        @elements = Element.trashed.includes(*element_includes)
        @page = Page.find(params[:page_id])
        @allowed_elements = @page.available_element_definitions
      end

      def clear
        @page = Page.find(params[:page_id])
        @elements = Element.trashed
        @elements.map(&:destroy)
      end

      private

      def element_includes
        [
          {
            contents: {
              essence: :ingredient_association,
            },
            all_nested_elements: [
              {
                contents: {
                  essence: :ingredient_association,
                },
              },
            ],
          },
        ]
      end
    end
  end
end
