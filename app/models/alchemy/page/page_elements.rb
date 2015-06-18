module Alchemy
  module Page::PageElements

    extend ActiveSupport::Concern

    included do
      attr_accessor :do_not_autogenerate

      has_many :elements, -> { order(:position) }
      has_many :contents, through: :elements
      has_and_belongs_to_many :to_be_sweeped_elements, -> { uniq },
        class_name: 'Alchemy::Element',
        join_table: ElementToPage.table_name

      after_create :autogenerate_elements, unless: -> { systempage? || do_not_autogenerate }
      after_update :trash_not_allowed_elements!, if: :page_layout_changed?
      after_update :autogenerate_elements, if: :page_layout_changed?

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
    # @option options [Alchemy::Cell || String] from_cell
    #   Return elements from given cell
    #
    # @return [ActiveRecord::Relation]
    #
    def find_elements(options = {}, show_non_public = false)
      elements = elements_from_cell_or_self(options[:from_cell])
      if options[:only].present?
        elements = elements.named(options[:only])
      elsif options[:except].present?
        elements = elements.excluded(options[:except])
      end
      if options[:reverse_sort] || options[:reverse]
        elements = elements.reverse_order
      end
      elements = elements.offset(options[:offset]).limit(options[:count])
      if options[:random]
        elements = elements.order("RAND()")
      end
      show_non_public ? elements : elements.published
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
    def available_element_definitions(only_element_named = nil)
      @_element_definitions = element_definitions
      return [] if @_element_definitions.blank?

      @_existing_element_names = elements.not_trashed.pluck(:name)
      delete_unique_element_definitions!
      delete_outnumbered_element_definitions!

      @_element_definitions
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
      @_element_definitions ||= element_definitions_by_name(element_definition_names)
    end

    # All names of elements that are defined in the corresponding
    # page and cell definition.
    #
    # Assign elements to a page in +config/alchemy/page_layouts.yml+ and/or
    # +config/alchemy/cells.yml+ file.
    #
    # == Example of page_layouts.yml:
    #
    #   - name: contact
    #     cells: [right_column]
    #     elements: [headline, contactform]
    #
    # == Example of cells.yml:
    #
    #   - name: right_column
    #     elements: [teaser]
    #
    def element_definition_names
      element_names_from_definition | element_names_from_cell_definitions
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

    # Returns an array of all EssenceRichtext contents ids
    #
    def richtext_contents_ids
      contents.essence_richtexts.pluck("#{Content.table_name}.id")
    end

    private

    def element_names_from_definition
      definition['elements'] || []
    end

    def element_names_from_cell_definitions
      @_element_names_from_cell_definitions ||= cell_definitions.map do |d|
        d['elements']
      end.flatten
    end

    # Looks in the page_layout descripion, if there are elements to autogenerate.
    #
    # And if so, it generates them.
    #
    # If the page has cells, it looks if there are elements to generate.
    #
    def autogenerate_elements
      elements_already_on_page = self.elements.available.pluck(:name)
      elements = self.layout_description["autogenerate"]
      if elements.present?
        elements.each do |element|
          next if elements_already_on_page.include?(element)
          Element.create_from_scratch(attributes_for_element_name(element))
        end
      end
    end

    # Returns a hash of attributes for given element name
    def attributes_for_element_name(element)
      element_cell_definition = cell_definitions.detect { |c| c['elements'].include?(element) }
      if has_cells? && element_cell_definition
        cell = cells.find_by!(name: element_cell_definition['name'])
        {page_id: id, cell_id: cell.id, name: element}
      else
        {page_id: id, name: element}
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

    # Deletes unique and already present definitions from @_element_definitions.
    #
    def delete_unique_element_definitions!
      @_element_definitions.delete_if do |element|
        element['unique'] && @_existing_element_names.include?(element['name'])
      end
    end

    # Deletes limited and outnumbered definitions from @_element_definitions.
    #
    def delete_outnumbered_element_definitions!
      @_element_definitions.delete_if do |element|
        outnumbered = @_existing_element_names.select { |name| name == element['name'] }
        element['amount'] && outnumbered.count >= element['amount'].to_i
      end
    end

    # Returns elements either from given cell or self
    #
    def elements_from_cell_or_self(cell)
      case cell.class.name
      when 'Alchemy::Cell'
        cell.elements
      when 'String'
        cell_elements_by_name(cell)
      else
        self.elements.not_in_cell
      end
    end

    # Returns all elements from given cell name
    #
    def cell_elements_by_name(name)
      if cell = cells.find_by_name(name)
        cell.elements
      else
        Alchemy::Logger.warn("Cell with name `#{name}` could not be found!", caller.first)
        Element.none
      end
    end
  end
end
