# frozen_string_literal: true

module Alchemy
  module Admin
    module PageDefinitionsHelper
      # Returns true if the technical or translated name of the page definition
      # or of any of its elements, including nested ones, contains the query.
      #
      # @param [Alchemy::PageDefinition]
      # @param [String, nil]
      # @return [Boolean]
      def page_definition_matches?(page_definition, query)
        return true if query.blank?

        names_match?(query, page_definition.name, page_definition.human_name) ||
          page_definition.elements.any? { element_definition_matches?(_1, query) }
      end

      # Returns true if the technical or translated name of the element
      # or of any of its nested elements contains the query.
      #
      # @param [String] element name
      # @param [String] query
      # @return [Boolean]
      def element_definition_matches?(name, query, seen = Set.new)
        return false unless seen.add?(name)

        names_match?(query, name, Alchemy::Element.display_name_for(name)) ||
          nested_element_matches?(name, query, seen)
      end

      # Returns true if any nested element of the element matches the query.
      #
      # @param [String] element name
      # @param [String] query
      # @return [Boolean]
      def nested_element_matches?(name, query, seen = Set[name])
        definition = Alchemy::ElementDefinition.get(name)
        return false unless definition

        definition.nestable_elements.any? { element_definition_matches?(_1, query, seen) }
      end

      private

      def names_match?(query, *names)
        names.any? { _1.to_s.downcase.include?(query.downcase) }
      end
    end
  end
end
