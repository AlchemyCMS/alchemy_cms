# frozen_string_literal: true

module Alchemy
  module Ingredients
    class TextEditor < BaseEditor
      def input_field
        tag.div(class: "input-field") do
          concat text_field_tag(form_field_name,
            value,
            class: settings[:linkable] ? "text_with_icon" : "",
            id: form_field_id,
            minlength: length_validation&.fetch(:minimum, nil),
            maxlength: length_validation&.fetch(:maximum, nil),
            required: presence_validation?,
            pattern: format_validation,
            readonly: cannot?(:edit, ingredient),
            type: settings[:input_type] || "text")

          if settings[:anchor]
            concat render(
              "alchemy/ingredients/shared/anchor",
              ingredient_editor: ingredient
            )
          end

          if settings[:linkable]
            concat hidden_field_tag(form_field_name(:link), ingredient.link, "data-link-value": true, id: nil)
            concat hidden_field_tag(form_field_name(:link_title), ingredient.link_title, "data-link-title": true, id: nil)
            concat hidden_field_tag(form_field_name(:link_class_name), ingredient.link_class_name, "data-link-class": true, id: nil)
            concat hidden_field_tag(form_field_name(:link_target), ingredient.link_target, "data-link-target": true, id: nil)
            concat render(
              "alchemy/ingredients/shared/link_tools",
              ingredient_editor: ingredient,
              ingredient:,
              wrapper_class: "ingredient_link_buttons"
            )
          end
        end
      end
    end
  end
end
