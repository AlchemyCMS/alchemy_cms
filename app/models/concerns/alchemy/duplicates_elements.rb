# frozen_string_literal: true

module Alchemy
  # Shared element-copying logic for +Alchemy::DuplicateElement+ (a pure copy of
  # an element and all of its nested elements) and +Alchemy::PublishElement+ (a
  # copy of an element and only its publishable nested elements onto a public
  # page version).
  #
  # Including classes must implement +#nested_elements+, returning the child
  # elements to copy.
  module DuplicatesElements
    SKIPPED_ATTRIBUTES_ON_COPY = [
      "cached_tag_list",
      "created_at",
      "creator_id",
      "position",
      "id",
      "folded",
      "updated_at",
      "updater_id"
    ]

    def initialize(source_element, repository: source_element.page_version.element_repository)
      @source_element = source_element
      @repository = repository
    end

    # Copies the source element (and its nested elements) into a new element.
    #
    # Pass a +differences+ Hash to override attributes on the copy.
    def call(differences = {})
      new_element = build_new_element(differences)
      new_element.save!
      duplicate_nested_elements(new_element)
      new_element
    end

    protected

    attr_reader :source_element, :repository

    # Builds (but does not save) the copy of the source element. Override this
    # to set attributes on the copy before it is persisted.
    def build_new_element(differences)
      attributes = source_element.attributes.with_indifferent_access
        .except(*SKIPPED_ATTRIBUTES_ON_COPY)
        .merge(differences)
        .merge(
          autogenerate_ingredients: false,
          autogenerate_nested_elements: false,
          tags: source_element.tags
        )

      new_element = Element.new(attributes)
      new_element.ingredients = source_element.ingredients.map(&:dup)
      new_element
    end

    # The nested (child) elements to copy.
    def nested_elements
      repository.children_of(source_element)
    end

    private

    def duplicate_nested_elements(new_element)
      Element.acts_as_list_no_update do
        nested_elements.each.with_index(1) do |nested_element, position|
          self.class.new(nested_element, repository: repository).call(
            parent_element: new_element,
            page_version: new_element.page_version,
            position: position
          )
        end
      end
    end
  end
end
