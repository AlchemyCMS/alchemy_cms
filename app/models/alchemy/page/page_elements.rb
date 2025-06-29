# frozen_string_literal: true

module Alchemy
  class Page < BaseRecord
    module PageElements
      extend ActiveSupport::Concern

      included do
        attr_accessor :autogenerate_elements

        with_options(
          class_name: "Alchemy::Element",
          through: :public_version,
          inverse_of: :page,
          source: :elements
        ) do
          has_many :all_elements
          has_many :elements, -> { not_nested.unfixed.published }
          has_many :fixed_elements, -> { fixed.published }
        end

        has_many :ingredients, through: :elements
        has_and_belongs_to_many :to_be_swept_elements, -> { distinct },
          class_name: "Alchemy::Element",
          join_table: ElementToPage.table_name

        after_create :generate_elements,
          unless: -> { autogenerate_elements == false }
      end

      module ClassMethods
        # Copy page elements
        #
        # @param source [Alchemy::Page]
        # @param target [Alchemy::Page]
        # @return [Array]
        #
        def copy_elements(source, target)
          repository = source.draft_version.element_repository
          elements = repository.not_nested
          page_version = target.draft_version
          duplicate_elements(elements.unfixed, repository, page_version) +
            duplicate_elements(elements.fixed, repository, page_version)
        end

        private

        def duplicate_elements(elements, repository, page_version)
          transaction do
            Element.acts_as_list_no_update do
              elements.each.with_index(1) do |element, position|
                Alchemy::DuplicateElement.new(element, repository: repository).call(
                  page_version_id: page_version.id,
                  position: position
                )
              end
            end
          end
        end
      end

      # All available element definitions that can actually be placed on current page.
      #
      # It extracts all definitions that are unique or limited and already on page.
      #
      # == Example of unique element:
      #
      #   - name: headline
      #     unique: true
      #     ingredients:
      #     - name: headline
      #       type: Text
      #
      # == Example of limited element:
      #
      #   - name: article
      #     amount: 2
      #     ingredients:
      #     - name: text
      #       type: Richtext
      #
      def available_element_definitions(only_element_named = nil)
        @_available_element_definitions ||= if only_element_named
          element_definition = Element.definition_by_name(only_element_named)
          element_definitions_by_name(element_definition.nestable_elements)
        else
          element_definitions.dup
        end

        return [] if @_available_element_definitions.blank?

        existing_elements = draft_version.elements.not_nested
        @_existing_element_names = existing_elements.pluck(:name)
        delete_unique_element_definitions!
        delete_outnumbered_element_definitions!

        @_available_element_definitions
      end

      # All names of elements that can actually be placed on current page.
      #
      def available_element_names
        @_available_element_names ||= available_element_definitions.map(&:name)
      end

      # Available element definitions excluding nested unique elements.
      #
      def available_elements_within_current_scope(parent)
        @_available_elements = if parent
          parents_unique_nested_elements = parent.nested_elements.where(unique: true).pluck(:name)
          available_element_definitions(parent.name).reject do |e|
            parents_unique_nested_elements.include?(e.name)
          end
        else
          available_element_definitions
        end
      end

      # All element definitions defined for page's page layout
      #
      # Warning: Since elements can be unique or limited in number,
      # it is more safe to ask for +available_element_definitions+
      #
      def element_definitions
        @_element_definitions ||= element_definitions_by_name(element_definition_names)
      end

      # All element definitions defined for page's page layout including nestable element definitions
      #
      def descendent_element_definitions
        definitions = element_definitions_by_name(element_definition_names)
        definitions.select { _1.nestable_elements.any? }.flat_map do |d|
          element_definitions_by_name(d.nestable_elements)
        end.uniq(&:name)
      end

      # All names of elements that are defined in the page definition.
      #
      # Assign elements to a page in +config/alchemy/page_layouts.yml+.
      #
      # == Example of page_layouts.yml:
      #
      #   - name: contact
      #     elements: [headline, contactform]
      #
      def element_definition_names
        definition.elements || []
      end

      # Element definitions with given name(s)
      #
      # @param [Array || String]
      #   one or many Alchemy::Element names. Pass +'all'+ to get all Element definitions
      # @return [Array]
      #   An Array of element definitions
      #
      def element_definitions_by_name(names)
        return [] if names.blank?

        if names.to_s == "all"
          Element.definitions
        else
          Element.definitions.select { names.include?(_1.name) }
        end
      end

      # Returns an array of all Richtext ingredients ids from not folded elements
      #
      def richtext_ingredients_ids
        Alchemy::Ingredient.richtexts.joins(:element)
          .where(Element.table_name => {page_version_id: draft_version.id, folded: false})
          .select(&:has_tinymce?)
          .collect(&:id)
      end

      private

      # Looks in the page_layout descripion, if there are elements to autogenerate.
      #
      # And if so, it generates them.
      #
      def generate_elements
        definition.autogenerate&.each do |element_name|
          Element.create(page: self, page_version: draft_version, name: element_name)
        end
      end

      # Deletes unique and already present definitions from @_available_element_definitions.
      #
      def delete_unique_element_definitions!
        @_available_element_definitions.delete_if do |element|
          element.unique && @_existing_element_names.include?(element.name)
        end
      end

      # Deletes limited and outnumbered definitions from @_available_element_definitions.
      #
      def delete_outnumbered_element_definitions!
        @_available_element_definitions.delete_if do |element|
          outnumbered = @_existing_element_names.select { |name| name == element.name }
          element.amount && outnumbered.count >= element.amount
        end
      end
    end
  end
end
