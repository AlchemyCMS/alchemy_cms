# frozen_string_literal: true

module Alchemy
  module Admin
    module ModelsHelper

      def get_content_settings(content)
        model = Object.const_get(content.settings_value(:model).to_s)
        return {
          model: content.settings_value(:model),
          scope: content.settings_value(:scope),
          search_field_name: (content.settings_value(:search_attributes) || model.attribute_names).join('_or_') + '_cont',
          display_attributes: content.settings_value(:display_attributes) || [:id],
          attribute_separator: content.settings_value(:attribute_separator) || ' > '
        }
      end

      def get_results_for_select(models, settings)
        models.collect { |model| {
            id: model[:id],
            text: get_display_text_for(model, settings)
          }
        }
      end

      def get_display_text_for(model, settings)
        parts = []
        settings[:display_attributes].each do |attribute|
          obj = model
          attribute.to_s.split('.').each do |attribute_part|
            obj = obj.send(attribute_part.to_sym)
          end
          parts << obj.to_s
        end
        parts.join(settings[:attribute_separator])
      end

    end
  end
end
