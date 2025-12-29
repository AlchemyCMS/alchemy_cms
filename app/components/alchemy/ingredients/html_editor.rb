# frozen_string_literal: true

module Alchemy
  module Ingredients
    class HtmlEditor < BaseEditor
      def input_field(form)
        form.text_area(:value, id: form_field_id)
      end
    end
  end
end
