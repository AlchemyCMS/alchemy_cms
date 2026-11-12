# frozen_string_literal: true

module Alchemy
  module Liquid
    module Tags
      # Renders elements with +render_elements+.
      #
      #   {% elements %}
      #   {% elements only: "article,text" %}
      #   {% elements except: excluded_names %}
      #
      # Given a collection of elements it renders those instead, e.g. the
      # nested elements of an element:
      #
      #   {% elements element.nested_elements %}
      #
      # +only+ and +except+ accept an array or a comma separated string.
      class Elements < ::Liquid::Tag
        include Arguments

        def initialize(tag_name, markup, parse_context)
          super
          parse_arguments(markup)
        end

        def render_to_output_buffer(context, output)
          view = view(context)
          options = attributes(context).slice(:only, :except).transform_values { names(_1) }.compact
          output << if @positional
            render_collection(view, positional(context), **options)
          else
            view.render_elements(options)
          end.to_s
          output
        end

        private

        def render_collection(view, collection, only: nil, except: nil)
          elements = Array(collection).map { Alchemy::Liquid.unwrap(_1) }.grep(Alchemy::Element)
          elements = elements.select { only.include?(_1.name) } if only
          elements = elements.reject { except.include?(_1.name) } if except
          view.safe_join(elements.each_with_index.map { |element, i| view.render_element(element, {}, i + 1) })
        end

        def names(value)
          case value
          when nil then nil
          when String then value.split(",").map(&:strip)
          else Array(value).map(&:to_s)
          end
        end
      end
    end
  end
end
