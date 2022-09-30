# frozen_string_literal: true

module Alchemy
  # Returns a dom id used for elements html id tag.
  #
  # Uses the elements name and its position on the page.
  # If the element is nested in a parent element it prefixes
  # the id with the parent elements dom_id.
  #
  # Register your own dom id class with
  #
  #  Alchemy::Element.dom_id_class = MyDomIdClass
  #
  class Element < BaseRecord
    class DomId
      def initialize(element)
        @element = element
        @parent_element = element.parent_element
      end

      def call
        [parent_element&.dom_id, element.name, element.position].compact.join("-")
      end

      private

      attr_reader :element, :parent_element
    end
  end
end
