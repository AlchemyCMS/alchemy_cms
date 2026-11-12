# frozen_string_literal: true

module Alchemy
  module Liquid
    module Tags
      # Renders an ingredient with its view component
      # (+Alchemy::Ingredients::*View+).
      #
      #   {% ingredient "headline" %}
      #   {% ingredient "picture", size: "600x400", crop: true %}
      #   {% ingredient element.ingredients.text %}
      #   {% ingredient "text", element: other_element %}
      #
      # A role is looked up on the +element+ variable, unless another element
      # is given. All other arguments are passed to the view component.
      class Ingredient < ::Liquid::Tag
        include Arguments

        def initialize(tag_name, markup, parse_context)
          super
          parse_arguments(markup)
          raise ::Liquid::SyntaxError, "The 'ingredient' tag needs a role or an ingredient" unless @positional
        end

        def render_to_output_buffer(context, output)
          options = attributes(context)
          element = options.delete(:element)
          ingredient = find_ingredient(context, positional(context), element)
          if ingredient
            output << view(context).render(ingredient.as_view_component(options: options)).to_s
          end
          output
        end

        private

        def find_ingredient(context, target, element)
          case target
          when Drops::IngredientDrop then target.record
          when String, Symbol then element_from(context, element).ingredient_by_role(target)
          when nil then nil
          else
            raise ::Liquid::ArgumentError, "The 'ingredient' tag needs a role or an ingredient"
          end
        end
      end
    end
  end
end
