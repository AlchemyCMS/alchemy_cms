module Alchemy
  module Page::PageElements

    extend ActiveSupport::Concern

    included do
      attr_accessor :do_not_autogenerate

      has_many :elements, -> { order(:position) }
      has_many :contents, :through => :elements
      has_and_belongs_to_many :to_be_sweeped_elements, -> { uniq }, class_name: 'Alchemy::Element', join_table: 'alchemy_elements_alchemy_pages'

      after_create :autogenerate_elements, :unless => proc { systempage? || do_not_autogenerate }
      after_update :trash_not_allowed_elements, :if => :page_layout_changed?
      after_update :autogenerate_elements, :if => :page_layout_changed?
      after_destroy { elements.each { |el| el.destroy unless el.trashed? } }
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
        source.elements.not_trashed.each do |element|
          # detect cell for element
          if element.cell
            cell = target.cells.detect { |c| c.name == element.cell.name }
          else
            cell = nil
          end
          # if cell is nil also pass nil to element.cell_id
          new_element = Element.copy(element, :page_id => target.id, :cell_id => (cell.blank? ? nil : cell.id))
          # move element to bottom of the list
          new_element.move_to_bottom
          new_elements << new_element
        end
        new_elements
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
    def available_element_definitions
      @elements_for_layout ||= element_definitions
      return [] if @elements_for_layout.blank?
      @page_element_names = elements.not_trashed.pluck(:name)
      delete_unique_element_definitions!
      delete_outnumbered_element_definitions!
      @elements_for_layout
    end

    # All names of elements that can actually be placed on current page.
    #
    def available_element_names
      available_element_definitions.collect { |e| e['name'] }
    end

    # All element definitions defined for page's page layout
    #
    def element_definitions
      element_definitions_by_name(element_definition_names)
    end

    # All names of elements that are defined in the page's page_layout definition.
    #
    # Define elements in +config/alchemy/page_layout.yml+ file
    #
    # == Example:
    #
    #   - name: contact
    #     elements: [headline, contactform]
    #
    def element_definition_names
      definition['elements'] || []
    end

    # Returns Element definitions with given name(s)
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
      contents.essence_richtexts.pluck('alchemy_contents.id')
    end

    private

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
      if self.has_cells? && (cell_definition = cell_definitions.detect { |c| c['elements'].include?(element) })
        cell = self.cells.find_by_name(cell_definition['name'])
        if cell
          return {:page_id => self.id, :cell_id => cell.id, :name => element}
        else
          raise "Cell not found for page #{self.inspect}"
        end
      else
        return {:page_id => self.id, :name => element}
      end
    end

    # Trashes all elements that are not allowed for this page_layout.
    def trash_not_allowed_elements
      elements.select { |e| !definition['elements'].include?(e.name) }.map(&:trash!)
    end

    # Deletes unique and already present definitions from @elements_for_layout.
    #
    def delete_unique_element_definitions!
      @elements_for_layout.delete_if { |element|
        element['unique'] && @page_element_names.include?(element['name'])
      }
    end

    # Deletes limited and outnumbered definitions from @elements_for_layout.
    #
    def delete_outnumbered_element_definitions!
      @elements_for_layout.delete_if { |element|
        element['amount'] && @page_element_names.select { |i| i == element['name'] }.count >= element['amount'].to_i
      }
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
