# frozen_string_literal: true

module Alchemy
  class DuplicateElement
    SKIPPED_ATTRIBUTES_ON_COPY = [
      "cached_tag_list",
      "created_at",
      "creator_id",
      "position",
      "id",
      "folded",
      "updated_at",
      "updater_id",
    ].freeze

    attr_reader :source_element, :repository

    def initialize(source_element, repository: source_element.page_version.element_repository)
      @source_element = source_element
      @repository = repository
    end

    def call(differences = {})
      attributes = source_element.attributes.with_indifferent_access
        .except(*SKIPPED_ATTRIBUTES_ON_COPY)
        .merge(differences)
        .merge(
          autogenerate_contents: false,
          autogenerate_ingredients: false,
          autogenerate_nested_elements: false,
          tags: source_element.tags,
        )

      new_element = Element.new(attributes)
      new_element.ingredients = source_element.ingredients.map(&:dup)
      new_element.save!

      source_element.contents.map do |content|
        Content.copy(content, element: new_element)
      end

      nested_elements = repository.children_of(source_element)
      Element.acts_as_list_no_update do
        nested_elements.each.with_index(1) do |nested_element, position|
          self.class.new(nested_element, repository: repository).call(
            parent_element: new_element,
            page_version: new_element.page_version,
            position: position
          )
        end
      end

      new_element
    end
  end
end
