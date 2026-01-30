# frozen_string_literal: true

module Alchemy
  module Ingredients
    class DatetimeEditor < BaseEditor
      delegate :alchemy_datepicker, to: :helpers

      def input_field
        tag.div(class: "input-field") do
          concat alchemy_datepicker(
            ingredient, :value, {
              name: form_field_name,
              id: form_field_id,
              value: value,
              type: settings[:input_type],
              disabled: !editable?
            }
          )
          concat tag.label(
            render_icon(:calendar),
            for: form_field_id,
            class: "ingredient-date--label"
          )
        end
      end
    end
  end
end
