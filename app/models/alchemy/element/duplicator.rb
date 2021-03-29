# frozen_string_literal: true

module Alchemy
  class Element < BaseRecord
    class Duplicator
      SKIPPED_ATTRIBUTES_ON_COPY = [
        "cached_tag_list",
        "created_at",
        "creator_id",
        "id",
        "folded",
        "position",
        "updated_at",
        "updater_id",
      ].freeze

      attr_reader :source_element, :repository

      def initialize(source_element, repository: source_element.page_version.element_repository)
        @source_element = source_element
        @repository = repository
      end

      def duplicate(differences = {})
        attributes = source_element.attributes.with_indifferent_access
          .except(*SKIPPED_ATTRIBUTES_ON_COPY)
          .merge(differences)
          .merge({
            autogenerate_contents: false,
            autogenerate_nested_elements: false,
            tag_list: source_element.tag_list,
          })

        new_element = Element.create(attributes)

        source_element.contents.map do |content|
          Content.copy(content, element: new_element)
        end

        nested_elements = repository.children_of(source_element)
        nested_elements.map do |nested_element|
          self.class.new(nested_element, repository: repository).duplicate(
            parent_element: new_element,
            page_version: new_element.page_version,
          )
        end

        new_element
      end
    end
  end
end
