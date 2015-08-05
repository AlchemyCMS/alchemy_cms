module Alchemy
  module Page::PageElements

    extend ActiveSupport::Concern

    included do
      attr_accessor :do_not_autogenerate

      has_many :elements, -> { Element.unnested.not_trashed.order(:position) }
      has_many :trashed_elements,
        -> { Element.trashed.order(:position) },
        class_name: 'Alchemy::Element'
      has_many :descendent_elements,
        -> { Element.not_trashed.order(:position) },
        class_name: 'Alchemy::Element'
      has_many :fixed_elements,
        -> { Element.fixed.not_trashed.order(:position) },
        class_name: 'Alchemy::Element'
      has_many :unfixed_elements,
        -> { Element.unfixed.not_trashed.order(:position) },
        class_name: 'Alchemy::Element'
      has_many :contents, through: :elements
      has_many :descendent_contents,
        through: :descendent_elements,
        class_name: 'Alchemy::Content',
        source: :contents
      has_and_belongs_to_many :to_be_swept_elements, -> { uniq },
        class_name: 'Alchemy::Element',
        join_table: ElementToPage.table_name

      after_create :autogenerate_elements!, unless: -> { systempage? || do_not_autogenerate }
      after_update :trash_not_allowed_elements!, if: :page_layout_changed?
      after_update :autogenerate_elements!, if: :page_layout_changed?

      after_destroy do
        elements.each do |element|
          next if element.trashed?
          element.destroy
        end
      end
    end

    module ClassMethods

      # Copy page elements
      #
      # @param source [Alchemy::Page]
      # @param target [Alchemy::Page]
      # @return [Array]
      #
      def copy_elements(source, target)
        new_elements = []
        source.elements.not_trashed.each do |source_element|
          cell = nil
          if source_element.cell
            cell = target.cells.find_by(name: source_element.cell.name)
          end
          new_element = Element.copy source_element, {
            page_id: target.id,
            cell_id: cell.try(:id)
          }
          new_element.move_to_bottom
          new_elements << new_element
        end
        new_elements
      end
    end

    # Finds elements of page.
    #
    # @param [Hash]
    #   options hash
    # @param [Boolean] (false)
    #   Pass true, if you want to also have not published elements.
    #
    # @option options [Array] only
    #   Returns only elements with given names
    # @option options [Array] except
    #   Returns all elements except the ones with given names
    # @option options [Fixnum] count
    #   Limit the count of returned elements
    # @option options [Fixnum] offset
    #   Starts with an offset while returning elements
    # @option options [Boolean] random (false)
    #   Return elements randomly shuffled
    #
    # @return [ActiveRecord::Relation]
    #
    def find_elements(options = {}, show_non_public = false)
      @_elements = if options[:only].present?
                     elements.named(options[:only])
                   elsif options[:except].present?
                     elements.excluded(options[:except])
                   end

      if options[:reverse_sort] || options[:reverse]
        @_elements = @_elements.reverse_order
      end

      @_elements = @_elements.offset(options[:offset]).limit(options[:count])

      if options[:random]
        @_elements = @_elements.order("RAND()")
      end

      show_non_public ? @_elements : @_elements.published
    end
    alias_method :find_selected_elements, :find_elements

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
    def available_element_definitions(only_element_named = nil, only_fixed_elements = false)
      @_available_element_definitions ||= if only_element_named
        definition = Element.definition_by_name(only_element_named)
        element_definitions_by_name(definition['nestable_elements'])
      else
        element_definitions
      end

      return [] if @_available_element_definitions.blank?

      @_existing_element_names = elements.pluck(:name)

      delete_unique_element_definitions!
      delete_outnumbered_element_definitions!

      @_available_element_definitions.reject! do |definition|
        if only_fixed_elements
          definition['fixed'] != true
        else
          definition['fixed'] == true
        end
      end

      @_available_element_definitions
    end

    # All names of elements that can actually be placed on current page.
    #
    def available_element_names
      @_available_element_names ||= available_element_definitions.map { |e| e['name'] }
    end

    # All element definitions defined for page's page layout
    #
    # Warning: Since elements can be unique or limited in number,
    # it is more safe to ask for +available_element_definitions+
    #
    def element_definitions
      @_element_definitions ||= element_definitions_by_name(defined_element_names)
    end

    # All names of elements that are defined in the page definition.
    #
    # Assign elements to a page in +config/alchemy/page_layouts.yml+
    #
    # == Example of page_layouts.yml:
    #
    #   - name: contact
    #     elements: [headline, contactform]
    #
    def defined_element_names
      @_defined_element_names ||= definition.fetch('elements', []).uniq
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
        Element.definitions.select { |e| names.include? e['name'] }
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
      elements.named(definition['feed_elements'])
    end

    # Returns an array of all EssenceRichtext contents ids from not folded elements
    #
    def richtext_contents_ids
      descendent_contents
        .where(Element.table_name => {folded: false})
        .essence_richtexts
        .pluck("#{Content.table_name}.id")
    end

    # Returns true, if this page's page_layout defines fixed elements.
    def can_have_fixed_elements?
      fixed_element_definitions.try(:any?)
    end

    # Collection of all element definitions that are fixed
    def fixed_element_definitions
      @_fixed_element_definitions ||= element_definitions.find_all do |definition|
        definition['fixed'] == true
      end
    end

    private

    # Create elements listed in the page definition as autogenerate elements.
    #
    # == Example Page Layout with autogenerate elements:
    #
    #     # config/alchemy/page_layouts.yml
    #     - name: contact
    #       autogenerate:
    #       - contactform
    #
    def autogenerate_elements!
      element_names_already_on_page = elements.available.pluck(:name)
      element_names = definition["autogenerate"]
      return if element_names.blank?

      element_names.each do |name|
        next if element_names_already_on_page.include?(name)
        Element.create_from_scratch(page_id: id, name: name)
      end
    end

    # Trashes all elements that are not allowed for this page_layout.
    def trash_not_allowed_elements!
      not_allowed_elements = elements.where([
        "#{Element.table_name}.name NOT IN (?)",
        element_names_from_definition
      ])
      not_allowed_elements.to_a.map(&:trash!)
    end

    # Deletes unique and already present definitions from @_available_element_definitions.
    #
    def delete_unique_element_definitions!
      @_available_element_definitions.delete_if do |element|
        element['unique'] && @_existing_element_names.include?(element['name'])
      end
    end

    # Deletes limited and outnumbered definitions from @_element_definitions.
    #
    def delete_outnumbered_element_definitions!
      @_available_element_definitions.delete_if do |element|
        outnumbered = @_existing_element_names.select { |name| name == element['name'] }
        element['amount'] && outnumbered.count >= element['amount'].to_i
      end
    end
  end
end
