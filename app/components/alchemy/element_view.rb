module Alchemy
  # Renders ViewComponents for elements.
  #
  # Each element has a view component class living at Alchemy::Elements::MyElement
  #
  # === Example:
  #
  #   <%= render Alchemy::ElementView.with_collection(@page.elements) %>
  #
  class ElementView < ViewComponent::Base
    with_collection_parameter :element

    attr_reader :element

    # @param [Hash] options The options passed to the wrapper tag.
    # @option options [Symbol] :tag (:div) The tag used for the wrapper.
    def initialize(element:)
      @element = element
    end

    def call
      render element_view_component.new(element: element)
    end

    # Returns an element wrapper tag.
    #
    # Makes sure the element highlight and select features work
    # in the page edit preview by adding a `data-alchemy-element`
    # attribute to the wrapper.
    #
    # If you don't want a wrapping tag, just remove this from your element
    # views, but be aware that the element won't be highlighted in the preview
    # anymore.
    #
    def element_wrapper(**options, &content)
      if Alchemy::Current.preview_page?(element.page)
        options["data-alchemy-element"] = element.id
      end
      tag.send(options.delete(:tag) || :div, **options, &content)
    end

    # Returns given element's ingredient view component.
    #
    #     <%= render ingredient(:image, {size: "100x100"}, {class: "image") %>
    #
    # @param [Symbol] - Ingredient role
    # @return [Alchemy::Ingredients::BaseView|NilClass] - Ingredient view component
    def ingredient(role, options = {}, html_options = {})
      renderable = get_ingredient(role)
      return if renderable.nil?

      renderable.as_view_component(
        options: options,
        html_options: html_options
      )
    end

    # Returns the value of given element's ingredient role.
    #
    #     <h1><%= value(:headline) %></h1>
    #
    # @param [Symbol] - Ingredient role
    def value(role)
      element.value_for(role)
    end

    # Returns the ingredient object of given element's ingredient role.
    #
    #     <% date = get_ingredient(:date) %>
    #     <%= l(date.value) if date %>
    #
    # @param [Symbol] - Ingredient role
    # @return [Alchemy::Ingredient]
    def get_ingredient(role)
      element.ingredient_by_role(role)
    end

    # Returns true if the given ingredient role has a value.
    #
    #     <% if has?(:link) %>
    #       <%= link_to "Go here", value(:link) %>
    #     <% end %>
    #
    # @param [Symbol] - Ingredient role
    # @return [TrueClass|FalseClass]
    def has?(role)
      element.has_value_for?(role)
    end

    private

    def render?
      !!element_view_component
    end

    def element_view_component
      Alchemy::Elements.const_get(element.name.classify)
    rescue NameError => e
      Rails.logger.warn("[alchemy] Cannot find view component for element #{element.name}. #{e}")
      nil
    end
  end
end
