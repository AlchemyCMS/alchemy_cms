# frozen_string_literal: true

module Alchemy
  module Ingredients
    class BooleanEditor < BaseEditor
      def call
        tag.div(class: css_classes, data: data_attributes, id: dom_id(ingredient)) do
          concat ingredient_id_field
          concat label_tag(nil, for: form_field_id) {
            safe_join([
              hidden_field_tag(form_field_name, "0", id: nil),
              check_box_tag(form_field_name, "1", value, id: form_field_id),
              ingredient_role,
              render_hint_for(ingredient, size: "1x", fixed_width: false)
            ])
          }
        end
      end
    end
  end
end
