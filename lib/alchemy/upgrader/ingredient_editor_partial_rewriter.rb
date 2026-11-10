# frozen_string_literal: true

module Alchemy
  class Upgrader
    # Rewrites an ingredient editor partial into the template of an
    # ingredient editor component inheriting from +Alchemy::Ingredients::BaseEditor+.
    #
    # The partial got an +Alchemy::IngredientEditor+ decorator passed as local
    # named after the partial (ie. +text_editor+) and the +element_form+ builder.
    # Both do not exist in components, where the decorator methods are
    # methods of the component itself.
    class IngredientEditorPartialRewriter
      # Methods of the removed +Alchemy::IngredientEditor+ decorator that
      # +Alchemy::Ingredients::BaseEditor+ implements as well. Every other method
      # was delegated to the ingredient.
      EDITOR_METHODS = %w[
        css_classes
        data_attributes
        form_field_id
        form_field_name
        format_validation
        has_warnings?
        ingredient
        length_validation
        linked?
        presence_validation?
        translated_role
        validations
        warnings
      ].freeze

      # @param [String] source The partial source
      # @param [String] local_name The name of the decorator local (ie. +text_editor+)
      # @return [Array(String, Boolean)]
      #   The template source and whether it still needs to be migrated by hand
      def rewrite(source, local_name)
        local = Regexp.escape(local_name)
        template = source.dup

        template.gsub!(
          /(<%=\s*)element_form\.fields_for\(\s*:ingredients\s*,\s*#{local}(?:\.ingredient)?\s*\)(\s*do\s*\|\s*\w+\s*\|\s*-?%>)/
        ) do
          "#{$1}fields_for(\"element[ingredients_attributes][\#{form_field_counter}]\", ingredient)#{$2}<%= ingredient_id_field %>"
        end
        template.gsub!(/\bingredient_label\(\s*#{local}\s*\)/, "ingredient_label")
        template.gsub!(/\bingredient_label\(\s*#{local}\s*,\s*([^,()]+?)\s*\)/, 'ingredient_label(\1)')
        template.gsub!(/\brender_ingredient_role\(\s*#{local}\s*\)/, "ingredient_role")
        template.gsub!(/\bingredient_editor:\s*#{local}\b/, "ingredient: ingredient")
        template.gsub!(/\b#{local}\.(\w+[?!]?)/) do
          EDITOR_METHODS.include?($1) ? $1 : "ingredient.#{$1}"
        end
        template.gsub!(/\b#{local}\b(?![?!])/, "ingredient")

        unless template.include?("dom_id(ingredient)")
          template.sub!(/\bdata:\s*data_attributes\b/, "data: data_attributes, id: dom_id(ingredient)")
        end

        manual = template.match?(/\belement_form\b|\bingredient_label\(\s*ingredient\b|\bAlchemy::IngredientEditor\b/)

        [template, manual]
      end
    end
  end
end
