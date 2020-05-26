# frozen_string_literal: true

module Alchemy
  module Page::PageElements
    extend ActiveSupport::Concern

    included do
      attr_accessor :autogenerate_elements

      has_many :all_elements,
        -> { order(:position) },
        class_name: "Alchemy::Element",
        inverse_of: :page
      has_many :elements,
        -> { order(:position).not_nested.unfixed.available },
        class_name: "Alchemy::Element",
        inverse_of: :page
      has_many :trashed_elements,
        -> { Element.trashed.order(:position) },
        class_name: "Alchemy::Element",
        inverse_of: :page
      has_many :fixed_elements,
        -> { order(:position).fixed.available },
        class_name: "Alchemy::Element",
        inverse_of: :page
      has_many :dependent_destroyable_elements,
        -> { not_nested },
        class_name: "Alchemy::Element",
        dependent: :destroy
      has_many :contents, through: :elements
      has_and_belongs_to_many :to_be_swept_elements, -> { distinct },
        class_name: "Alchemy::Element",
        join_table: ElementToPage.table_name

      after_create :generate_elements,
        unless: -> { autogenerate_elements == false }

      after_update :trash_not_allowed_elements!,
        if: :saved_change_to_page_layout?

      after_update :generate_elements,
        if: :saved_change_to_page_layout?
    end

    module ClassMethods
      # Copy page elements
      #
      # @param source [Alchemy::Page]
      # @param target [Alchemy::Page]
      # @return [Array]
      #
      def copy_elements(source, target)
        source_elements = source.all_elements.not_nested.not_trashed
        source_elements.order(:position).map do |source_element|
          Element.copy(source_element, {
            page_id: target.id,
          }).tap(&:move_to_bottom)
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
    #     contents:
    #     - name: headline
    #       type: EssenceText
    #
    # == Example of limited element:
    #
    #   - name: article
    #     amount: 2
    #     contents:
    #     - name: text
    #       type: EssenceRichtext
    #
    def available_element_definitions(only_element_named = nil)
      @_element_definitions ||= if only_element_named
          definition = Element.definition_by_name(only_element_named)
          element_definitions_by_name(definition["nestable_elements"])
        else
          element_definitions
        end

      return [] if @_element_definitions.blank?

      existing_elements = all_elements.not_nested.not_trashed
      @_existing_element_names = existing_elements.pluck(:name)
      delete_unique_element_definitions!
      delete_outnumbered_element_definitions!

      @_element_definitions
    end

    # All names of elements that can actually be placed on current page.
    #
    def available_element_names
      @_available_element_names ||= available_element_definitions.map { |e| e["name"] }
    end

    # Available element definitions excluding nested unique elements.
    #
    def available_elements_within_current_scope(parent)
      @_available_elements = if parent
          parents_unique_nested_elements = parent.nested_elements.where(unique: true).pluck(:name)
          available_element_definitions(parent.name).reject do |e|
            parents_unique_nested_elements.include? e["name"]
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
      definitions.select { |d| d.key?("nestable_elements") }.each do |d|
        definitions += element_definitions_by_name(d["nestable_elements"])
      end
      definitions.uniq { |d| d["name"] }
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
      definition["elements"] || []
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
        Element.definitions.select { |e| names.include? e["name"] }
      end
    end

    # Returns all elements that should be feeded via rss.
    #
    # Define feedable elements in your +page_layouts.yml+:
    #
    #   - name: news
    #     feed: true
    #     feed_elements: [element_name, element_2_name]
    #
    def feed_elements
      elements.named(definition["feed_elements"])
    end

    # Returns an array of all EssenceRichtext contents ids from not folded elements
    #
    def richtext_contents_ids
      Alchemy::Content.joins(:element)
        .where(Element.table_name => { page_id: id, folded: false })
        .select(&:has_tinymce?)
        .collect(&:id)
    end

    private

    # Looks in the page_layout descripion, if there are elements to autogenerate.
    #
    # And if so, it generates them.
    #
    def generate_elements
      existing_elements = all_elements.not_nested.not_trashed
      existing_element_names = existing_elements.pluck(:name).uniq
      definition.fetch("autogenerate", []).each do |element_name|
        next if existing_element_names.include?(element_name)

        Element.create(page: self, name: element_name)
      end
    end

    # Trashes all elements that are not allowed for this page_layout.
    def trash_not_allowed_elements!
      not_allowed_elements = elements.where([
        "#{Element.table_name}.name NOT IN (?)",
        element_definition_names,
      ])
      not_allowed_elements.to_a.map(&:trash!)
    end

    # Deletes unique and already present definitions from @_element_definitions.
    #
    def delete_unique_element_definitions!
      @_element_definitions.delete_if do |element|
        element["unique"] && @_existing_element_names.include?(element["name"])
      end
    end

    # Deletes limited and outnumbered definitions from @_element_definitions.
    #
    def delete_outnumbered_element_definitions!
      @_element_definitions.delete_if do |element|
        outnumbered = @_existing_element_names.select { |name| name == element["name"] }
        element["amount"] && outnumbered.count >= element["amount"].to_i
      end
    end
  end
end
