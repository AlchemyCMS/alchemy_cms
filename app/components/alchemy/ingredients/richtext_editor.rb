# frozen_string_literal: true

module Alchemy
  module Ingredients
    class RichtextEditor < BaseEditor
      def input_field(form)
        content_tag("alchemy-tinymce", custom_tinymce_config) do
          form.text_area :value,
            minlength: length_validation&.fetch(:minimum, nil),
            maxlength: length_validation&.fetch(:maximum, nil),
            id: form_field_id(:value)
        end
      end

      private

      def custom_tinymce_config
        ingredient.custom_tinymce_config.each_with_object({}) do |(k, v), obj|
          obj[k.to_s.dasherize] = v.to_json
        end
      end
    end
  end
end
