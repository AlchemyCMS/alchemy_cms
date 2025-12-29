# frozen_string_literal: true

module Alchemy
  module Ingredients
    class LinkEditor < BaseEditor
      def input_field(form)
        tag.div(class: "input-field") do
          concat form.text_field(:value,
            class: "thin_border text_with_icon readonly",
            id: form_field_id,
            "data-link-value": true,
            minlength: length_validation&.fetch(:minimum, nil),
            maxlength: length_validation&.fetch(:maximum, nil),
            required: presence_validation?,
            pattern: format_validation,
            readonly: true,
            tabindex: -1)
          concat form.hidden_field(:link_title, "data-link-title": true, id: nil)
          concat form.hidden_field(:link_class_name, "data-link-class": true, id: nil)
          concat form.hidden_field(:link_target, "data-link-target": true, id: nil)
          concat render("alchemy/ingredients/shared/link_tools",
            ingredient_editor: ingredient,
            wrapper_class: "ingredient_link_buttons")
        end
      end
    end
  end
end
