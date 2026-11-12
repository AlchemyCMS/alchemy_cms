# frozen_string_literal: true

module Alchemy
  module Liquid
    # Filters available in Alchemy Liquid templates.
    module Filters
      # Translates a key with the Rails +t+ view helper. Keys starting
      # with a dot are looked up relative to the template.
      #
      #   {{ "read_more" | t }}
      #   {{ ".title" | t }}
      #   {{ "greeting" | t: name: page.name }}
      def t(key, options = {})
        FilterHelpers.view(@context).t(key.to_s, **FilterHelpers.symbolize(options))
      end

      # Returns the url of a page, node, or a Page, Node or Link ingredient.
      #
      #   {{ page | url }}
      #   {{ element.ingredients.link | url }}
      def url(input)
        FilterHelpers.url_for(Alchemy::Liquid.unwrap(input))
      end

      # Returns the url of a picture ingredient. Accepts the options of
      # +Alchemy::Ingredients::Picture#picture_url+.
      #
      #   {{ element.ingredients.image | picture_url: size: "300x200", crop: true }}
      def picture_url(input, options = {})
        ingredient = Alchemy::Liquid.unwrap(input)
        return unless ingredient.respond_to?(:picture_url)

        ingredient.picture_url(FilterHelpers.symbolize(options))
      end

      # Localizes a date or time with the Rails +l+ view helper.
      #
      #   {{ page.published_at | format_date }}
      #   {{ element.ingredients.date.value | format_date: "short" }}
      def format_date(input, format = "default")
        time = FilterHelpers.to_time(input)
        return if time.nil?

        FilterHelpers.view(@context).l(time, format: format.to_sym)
      end

      # Like the standard +escape+ filter, but does not escape values
      # that are already escaped (like the text values of Alchemy drops).
      def escape(input)
        (input.respond_to?(:html_safe?) && input.html_safe?) ? input : super
      end
      alias_method :h, :escape

      # Helpers kept outside of the filter module, so they can't be called
      # as filters from templates.
      module FilterHelpers
        module_function

        def view(context)
          context.registers[:view] ||
            raise(::Liquid::ContextError, "Alchemy Liquid filters need a view context in the :view register")
        end

        def symbolize(options)
          options.to_h.to_h { |key, value| [key.to_sym, Alchemy::Liquid.unwrap(value)] }
        end

        def url_for(object)
          case object
          when Alchemy::Page then object.url_path
          when Alchemy::Node then object.url
          when Alchemy::Ingredients::Page then object.page&.url_path
          when Alchemy::Ingredients::Node then object.node&.url
          when Alchemy::Ingredients::Link then object.value.presence
          when Alchemy::Ingredient then object.try(:link).presence
          when String then object
          end
        end

        def to_time(input)
          case input
          when Date, Time, DateTime, ActiveSupport::TimeWithZone then input
          when String then input.present? ? Time.zone.parse(input) : nil
          end
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
