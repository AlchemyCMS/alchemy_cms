# frozen_string_literal: true

module Alchemy
  module Ingredients
    class NumberEditor < BaseEditor
      def input_field
        tag.div(class: "input-field") do
          concat text_field_tag(form_field_name,
            value,
            type: settings[:input_type] || "number",
            required: presence_validation?,
            step: settings[:step],
            min: settings[:min],
            max: settings[:max],
            id: form_field_id,
            oninput: (settings[:input_type] == "range") ? "this.nextElementSibling.value = this.value" : nil)
          if settings[:input_type] == "range"
            concat tag.output(value)
          end
          if settings[:unit]
            concat tag.div(settings[:unit], class: "input-addon right")
          end
        end
      end
    end
  end
end
