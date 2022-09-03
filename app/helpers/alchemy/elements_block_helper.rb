# frozen_string_literal: true

module Alchemy
  # Provides a collection of block-level helpers, allowing for a much more
  # concise way of writing element view/editor partials.
  #
  module ElementsBlockHelper
    # Base class for our block-level helpers.
    #
    class BlockHelper
      attr_reader :helpers
      attr_reader :opts

      def initialize(helpers, opts = {})
        @helpers = helpers
        @opts = opts
      end

      def element
        opts[:element]
      end
    end

    # Block-level helper class for element views.
    #
    class ElementViewHelper < BlockHelper
      # Renders one of the element's contents.
      #
      # If the element uses +ingredients+ it renders the ingredient record.
      #
      def render(name, options = {}, html_options = {})
        renderable = element.ingredient_by_role(name) || Alchemy::Deprecation.silence { content(name) }
        return if renderable.nil?

        if Alchemy::DEPRECATED_ESSENCE_CLASSES.include?(renderable.try(:essence)&.class&.name)
          Alchemy::Deprecation.warn(
            "Using a '#{renderable.essence.class.name.demodulize}' content is deprecated. " \
            "Please use a '#{Alchemy::DEPRECATED_ESSENCE_CLASS_MAPPING[renderable.essence.class.name].demodulize}' ingredient instead."
          )
        end

        helpers.render(renderable, {
          options: options,
          html_options: html_options,
        })
      end

      # Returns one of the element's contents (ie. essence instances).
      #
      def content(name)
        element.content_by_name(name)
      end

      deprecate content: "Use `ingredient_by_role` instead", deprecator: Alchemy::Deprecation

      # Returns the ingredient of one of the element's contents.
      #
      # If the element uses +ingredients+ it returns the +value+ of the ingredient record.
      #
      def ingredient(name)
        element.ingredient(name)
      end

      # Returns the value of one of the element's ingredients.
      #
      def value(name)
        element.value_for(name)
      end

      # Returns true if the given content or ingredient has a value.
      #
      def has?(name)
        if element.ingredient_definitions.any?
          element.has_value_for?(name)
        else
          Alchemy::Deprecation.silence do
            element.has_ingredient?(name)
          end
        end
      end

      # Return's the given content's essence.
      #
      def essence(name)
        content(name).try(:essence)
      end

      deprecate essence: "Use `ingredient_by_role` instead", deprecator: Alchemy::Deprecation

      # Return's the ingredient record by given role.
      #
      def ingredient_by_role(role)
        element.ingredient_by_role(role)
      end
    end

    # Block-level helper for element views. Constructs a DOM element wrapping
    # your content element and provides a block helper object you can use for
    # concise access to Alchemy's various helpers.
    #
    # === Example:
    #
    #   <%= element_view_for(element) do |el| %>
    #     <%= el.render :title %>
    #     <%= el.render :body %>
    #     <%= link_to "Go!", el.ingredient(:target_url) %>
    #   <% end %>
    #
    # You can override the tag, ID and class used for the generated DOM
    # element:
    #
    #   <%= element_view_for(element, tag: 'span', id: 'my_id', class: 'thing') do |el| %>
    #      <%- ... %>
    #   <% end %>
    #
    # If you don't want your view to be wrapped into an extra element, simply set
    # `tag` to `false`:
    #
    #   <%= element_view_for(element, tag: false) do |el| %>
    #      <%- ... %>
    #   <% end %>
    #
    # @param [Alchemy::Element] element
    #   The element to display.
    # @param [Hash] options
    #   Additional options.
    #
    # @option options :tag (:div)
    #   The HTML tag to be used for the wrapping element.
    # @option options :id (the element's dom_id)
    #   The wrapper tag's DOM ID.
    # @option options :class (the element's essence name)
    #   The wrapper tag's DOM class.
    # @option options :tags_formatter
    #   A lambda used for formatting the element's tags (see Alchemy::ElementsHelper::element_tags_attributes). Set to +false+ to not include tags in the wrapper element.
    #
    def element_view_for(element, options = {})
      options = {
        tag: :div,
        id: element_dom_id(element),
        class: element.name,
        tags_formatter: ->(tags) { tags.join(" ") },
      }.merge(options)

      # capture inner template block
      output = capture do
        yield ElementViewHelper.new(self, element: element) if block_given?
      end

      # wrap output in a useful DOM element
      if tag = options.delete(:tag)
        # add preview attributes
        options.merge!(element_preview_code_attributes(element))

        # add tags
        if tags_formatter = options.delete(:tags_formatter)
          options.merge!(element_tags_attributes(element, formatter: tags_formatter))
        end

        output = content_tag(tag, output, options)
      end

      # that's it!
      output
    end
  end
end
