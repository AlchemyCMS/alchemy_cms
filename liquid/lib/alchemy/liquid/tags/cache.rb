# frozen_string_literal: true

module Alchemy
  module Liquid
    module Tags
      # Fragment caching with the Rails +cache+ view helper, so the cache key
      # contains the template digest, just like in ERB views.
      #
      #   {% cache element %}...{% endcache %}
      #   {% cache element, expires_in: 3600 %}...{% endcache %}
      class Cache < ::Liquid::Block
        include Arguments

        def initialize(tag_name, markup, parse_context)
          super
          parse_arguments(markup)
          raise ::Liquid::SyntaxError, "The 'cache' tag needs a cache key" unless @positional
        end

        def render_to_output_buffer(context, output)
          view = view(context)
          key = Alchemy::Liquid.unwrap(positional(context))
          options = attributes(context).slice(:expires_in, :skip_digest)
          fragment = view.capture do
            view.cache(key, options) do
              view.safe_concat(render_body(context))
            end
          end
          output << fragment.to_s
          output
        end

        def blank?
          false
        end

        private

        def render_body(context)
          @body.render(context).html_safe
        end
      end
    end
  end
end
