# frozen_string_literal: true

module Alchemy
  # Preloads element trees with all associations and nested elements
  #
  # This service efficiently loads element trees to avoid N+1 queries.
  # It recursively preloads all nested elements to unlimited depth.
  #
  # @example Preload elements for a page version
  #   preloader = Alchemy::ElementPreloader.new(page_version: page_version)
  #   preloaded_elements = preloader.call
  #
  class ElementPreloader
    # @param page_version [PageVersion] The page version to preload elements for
    def initialize(page_version:)
      @page_version = page_version
      ActiveRecord::Associations::Preloader.new(
        records: [page_version],
        associations: {page: :language}
      ).call
    end

    # Preloads and returns the element tree with all associations loaded
    #
    # @return [Array<Element>] Elements with preloaded nested elements
    def call
      # Load all elements for the page version with associations
      all_elements = load_all_elements
      return [] if all_elements.empty?

      # Build parent -> children lookup and populate associations
      populate_nested_associations(all_elements)

      # Root elements are those without a parent
      root_elements = all_elements.values
        .select { |e| e.parent_element_id.nil? }
        .sort_by(&:position)
      return [] if root_elements.empty?

      ElementsPreloader.call(all_elements.values)

      root_elements
    end

    private

    attr_reader :page_version

    # Load all elements for the page version and preload their associations
    def load_all_elements
      Element
        .where(page_version_id: page_version.id)
        .includes(ingredients: :related_object)
        .index_by(&:id)
    end

    # Populate the all_nested_elements association for each element
    def populate_nested_associations(elements_by_id)
      # Group elements by parent_id
      elements_by_parent = elements_by_id.values.group_by(&:parent_element_id)

      elements_by_id.each_value do |element|
        children = elements_by_parent[element.id] || []
        children = children.sort_by { |c| c.position.to_i }

        # Manually set the association target
        element.association(:all_nested_elements).target = children
        element.association(:all_nested_elements).loaded!
      end
    end
  end
end
