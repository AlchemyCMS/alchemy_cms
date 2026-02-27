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
    # @param language [Language, nil] Language for related object preloading (optional)
    def initialize(page_version:, language: nil)
      @page_version = page_version
      @language = language
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

      # Preload related objects if language is provided
      preload_related_objects(root_elements) if language

      root_elements
    end

    private

    attr_reader :page_version, :language

    # Load all elements for the page version and preload their associations
    def load_all_elements
      Element
        .where(page_version_id: page_version.id)
        .includes(*element_includes)
        .index_by(&:id)
    end

    # Populate the all_nested_elements association for each element
    def populate_nested_associations(elements_by_id)
      # Group elements by parent_id
      elements_by_parent = elements_by_id.values.group_by(&:parent_element_id)

      elements_by_id.each_value do |element|
        children = elements_by_parent[element.id] || []
        children = children.sort_by(&:position)

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

    # Collect unique related objects from element tree, grouped by class
    def collect_related_objects(elements, collected = Hash.new { |h, k| h[k] = {} })
      elements.each do |element|
        element.ingredients.each do |ingredient|
          obj = ingredient.related_object
          collected[obj.class][obj.id] = obj if obj
        end
        if element.association(:all_nested_elements).loaded?
          collect_related_objects(element.all_nested_elements, collected)
        end
      end
      collected.transform_values(&:values)
    end
  end
end
