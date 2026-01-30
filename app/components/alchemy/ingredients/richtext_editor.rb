# frozen_string_literal: true

module Alchemy
  module Ingredients
    class RichtextEditor < BaseEditor
      def input_field
        content_tag("alchemy-tinymce", tinymce_config) do
          text_area_tag form_field_name,
            value,
            minlength: length_validation&.fetch(:minimum, nil),
            maxlength: length_validation&.fetch(:maximum, nil),
            id: form_field_id(:value)
        end
      end

      private

      def tinymce_config
        config = custom_tinymce_config
        config["readonly"] = true.to_json if !editable?
        config
      end

      def custom_tinymce_config
        ingredient.custom_tinymce_config.each_with_object({}) do |(k, v), obj|
          obj[k.to_s.dasherize] = v.to_json
        end
      end
    end
  end
end
