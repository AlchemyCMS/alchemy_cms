# frozen_string_literal: true

module Alchemy
  module Ingredients
    class PageEditor < BaseEditor
      delegate :page, to: :ingredient

      def input_field(form)
        render Alchemy::Admin::PageSelect.new(page, allow_clear: true, query_params: settings[:query_params]) do
          form.text_field :page_id,
            value: page&.id,
            id: form_field_id(:page_id),
            class: "full_width"
        end
      end
    end
  end
end
