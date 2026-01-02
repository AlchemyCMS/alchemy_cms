# frozen_string_literal: true

module Alchemy
  module Ingredients
    class PageEditor < BaseEditor
      delegate :page, to: :ingredient

      def input_field
        render Alchemy::Admin::PageSelect.new(page, allow_clear: true, query_params: settings[:query_params]) do
          text_field_tag form_field_name(:page_id),
            page&.id,
            id: form_field_id(:page_id),
            class: "full_width"
        end
      end
    end
  end
end
