# frozen_string_literal: true

module Alchemy
  module Ingredients
    class HtmlEditor < BaseEditor
      def input_field
        text_area_tag(form_field_name, value, id: form_field_id, readonly: !editable?)
      end
    end
  end
end
