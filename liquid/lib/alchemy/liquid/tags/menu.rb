# frozen_string_literal: true

module Alchemy
  module Liquid
    module Tags
      # Renders a menu with +render_menu+.
      #
      #   {% menu "main_menu" %}
      #   {% menu "footer_menu", class: "footer" %}
      #
      # All other arguments are passed as options to the menu partials.
      class Menu < ::Liquid::Tag
        include Arguments

        def initialize(tag_name, markup, parse_context)
          super
          parse_arguments(markup)
          raise ::Liquid::SyntaxError, "The 'menu' tag needs a menu type" unless @positional
        end

        def render_to_output_buffer(context, output)
          output << view(context).render_menu(positional(context).to_s, attributes(context)).to_s
          output
        end
      end
    end
  end
end
