# frozen_string_literal: true

module Alchemy
  module Liquid
    module Tags
      # Wraps its content with +element_view_for+, which adds the attributes
      # the page preview needs to select the element in the admin.
      #
      #   {% element_view %}...{% endelement_view %}
      #   {% element_view element, tag: "section", class: "teaser" %}...{% endelement_view %}
      #   {% element_view tag: false %}...{% endelement_view %}
      #
      # Without an element argument the +element+ variable is used.
      class ElementView < ::Liquid::Block
        include Arguments

        def initialize(tag_name, markup, parse_context)
          super
          parse_arguments(markup)
        end

        def render_to_output_buffer(context, output)
          element = element_from(context, positional(context))
          options = attributes(context).slice(:tag, :class, :id)
          body = @body.render(context).html_safe
          output << view(context).element_view_for(element, options) { body }.to_s
          output
        end

        # Always renders the wrapper, even around blank content.
        def blank?
          false
        end
      end
    end
  end
end
