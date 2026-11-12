# frozen_string_literal: true

module Alchemy
  module Liquid
    module Tags
      # Parses tag markup of the form
      #
      #   [positional] [, key: value]*
      #
      # and gives access to the view context from the +:view+ register.
      module Arguments
        POSITIONAL = /\A\s*(?!\w[\w-]*\s*:)(#{::Liquid::QuotedFragment})/o
        KEY_VALUE = /\A\s*,?\s*(\w[\w-]*)\s*:\s*(#{::Liquid::QuotedFragment})/o

        private

        def parse_arguments(markup)
          rest = markup.to_s
          if (match = POSITIONAL.match(rest))
            @positional = parse_expression(match[1])
            rest = match.post_match
          end
          @attributes = {}
          while (match = KEY_VALUE.match(rest))
            @attributes[match[1]] = parse_expression(match[2])
            rest = match.post_match
          end
          unless rest.strip.empty?
            raise ::Liquid::SyntaxError, "Invalid arguments for '#{tag_name}' tag: #{markup.strip}"
          end
        end

        def positional(context)
          @positional && context.evaluate(@positional)
        end

        def attributes(context)
          @attributes.to_h do |key, expression|
            [key.to_sym, Alchemy::Liquid.unwrap(context.evaluate(expression))]
          end
        end

        def view(context)
          context.registers[:view] ||
            raise(::Liquid::ContextError, "The '#{tag_name}' tag needs a view context in the :view register")
        end

        # The record of the given drop, or of the +element+ variable.
        def element_from(context, value = nil)
          element = Alchemy::Liquid.unwrap(value || context["element"])
          unless element.is_a?(Alchemy::Element)
            raise ::Liquid::ArgumentError, "The '#{tag_name}' tag needs an element"
          end
          element
        end
      end
    end
  end
end
