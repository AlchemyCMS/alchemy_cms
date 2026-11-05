# frozen_string_literal: true

module Alchemy
  module Admin
    module PageDefinitionsHelper
      # Returns the path to the page definitions, filtered by page type
      # and with the search query to highlight.
      #
      # @param [String, nil] page type name
      # @param [String, nil] search query
      # @param [String, nil] anchor to scroll to
      # @return [String]
      def page_definitions_filter_path(page_type: nil, query: nil, anchor: nil)
        alchemy.admin_page_definitions_path(
          q: {name_eq: page_type, name_or_elements_cont: query}.compact_blank.presence,
          anchor: anchor
        )
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
