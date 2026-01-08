# frozen_string_literal: true

module Alchemy
  # Preloads element trees with all associations and nested elements
  #
  # This service efficiently loads element trees to avoid N+1 queries.
  # It recursively preloads all nested elements to unlimited depth.
  #
  # @example Preload elements for a page version
  #   preloader = Alchemy::ElementPreloader.new(elements: root_elements)
  #   preloaded_elements = preloader.call
  #
  class ElementPreloader
    # @param elements [ActiveRecord::Relation] Root elements to preload
    # @param language [Language, nil] Language for related object preloading (optional)
    def initialize(elements:, language: nil)
      @elements = elements
      @language = language
    end

    # Preloads and returns the element tree with all associations loaded
    #
    # @return [Array<Element>] Elements with preloaded nested elements
    def call
      return [] if elements.blank?

      # Load root elements with their immediate associations
      root_elements = elements.includes(*element_includes).to_a
      return root_elements if root_elements.empty?

      # Collect all element IDs and load all descendants
      page_version_id = root_elements.first.page_version_id
      all_elements = load_all_elements(page_version_id, root_elements)

      # Build parent -> children lookup and populate associations
      populate_nested_associations(all_elements)

      # Preload related objects if language is provided
      preload_related_objects(root_elements) if language

      root_elements
    end

    private

    attr_reader :elements, :language

    # Load all elements for the page version and preload their associations
    def load_all_elements(page_version_id, root_elements)
      # Load all elements that belong to this page version (including nested)
      # Ordering is handled in populate_nested_associations
      all_elements = Element
        .where(page_version_id: page_version_id)
        .includes(*element_includes)
        .index_by(&:id)

      # Replace root elements with preloaded versions from the hash
      root_elements.map! { |e| all_elements[e.id] || e }

      all_elements
    end

    # Populate the all_nested_elements association for each element
    def populate_nested_associations(elements_by_id)
      # Group elements by parent_id
      elements_by_parent = elements_by_id.values.group_by(&:parent_element_id)

      elements_by_id.each_value do |element|
        children = elements_by_parent[element.id] || []
        # Position is scoped by [page_version_id, fixed, parent_element_id]
        # Sort unfixed elements first, then fixed, each group by position
        children = children.sort_by { |e| [e.fixed? ? 1 : 0, e.position] }

        # Manually set the association target
        element.association(:all_nested_elements).target = children
        element.association(:all_nested_elements).loaded!
      end
    end

    # Associations to preload for element rendering
    def element_includes
      [
        {ingredients: :related_object},
        :tags
      ]
    end

    # Preload related objects for all ingredients in elements
    # Allows related objects to preload their associations (e.g., picture descriptions)
    def preload_related_objects(root_elements)
      related_objects_by_class = collect_related_objects(root_elements)
      return if related_objects_by_class.empty?

      related_objects_by_class.each do |klass, objects|
        if klass.respond_to?(:alchemy_element_preloads)
          klass.alchemy_element_preloads(objects, language: language)
        end
      end
    end

    # Collect all related objects from element tree, grouped by class
    def collect_related_objects(elements, collected = Hash.new { |h, k| h[k] = [] })
      elements.each do |element|
        element.ingredients.each do |ingredient|
          if ingredient.related_object
            collected[ingredient.related_object.class] << ingredient.related_object
          end
        end
        if element.association(:all_nested_elements).loaded?
          collect_related_objects(element.all_nested_elements, collected)
        end
      end
      collected
    end
  end
end
