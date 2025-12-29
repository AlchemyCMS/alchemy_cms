# frozen_string_literal: true

module Alchemy
  module Ingredients
    class BooleanEditor < BaseEditor
      def call
        tag.div(class: css_classes, data: data_attributes) do
          element_form.fields_for(:ingredients, ingredient) do |form|
            tag.label(:value, for: form_field_id) do
              concat form.check_box(:value, id: form_field_id)
              concat ingredient_role
              concat render_hint_for(ingredient, size: "1x", fixed_width: false)
            end
          end
        end
      end
    end
  end
end
