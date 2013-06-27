module Alchemy
  module Page::Elements

    extend ActiveSupport::Concern

    included do
      attr_accessor :do_not_autogenerate

      has_many :elements, :order => :position
      has_many :contents, :through => :elements
      has_and_belongs_to_many :to_be_sweeped_elements, :class_name => 'Alchemy::Element', :uniq => true, :join_table => 'alchemy_elements_alchemy_pages'

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
      @elements_for_layout = element_definitions_by_name(element_definition_names)
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

    # Finds selected elements from page.
    #
    # Returns only public elements by default.
    # Pass true as second argument to get all elements.
    #
    # === Options are:
    #
    #     :only => Array of element names    # Returns only elements with given names
    #     :except => Array of element names  # Returns all elements except the ones with given names
    #     :count => Integer                  # Limit the count of returned elements
    #     :offset => Integer                 # Starts with an offset while returning elements
    #     :random => Boolean                 # Return elements randomly shuffled
    #     :from_cell => Cell or String       # Return elements from given cell
    #
    def find_selected_elements(options = {}, show_non_public = false)
      if options[:from_cell].class.name == 'Alchemy::Cell'
        elements = options[:from_cell].elements
      elsif !options[:from_cell].blank? && options[:from_cell].class.name == 'String'
        cell = cells.find_by_name(options[:from_cell])
        if cell
          elements = cell.elements
        else
          Alchemy::Logger.warn "Cell with name `#{options[:from_cell]}` could not be found!", caller.first
          # Returns an empty relation. Can be removed with the release of Rails 4
          elements = self.elements.where('1 = 0')
        end
      else
        elements = self.elements.not_in_cell
      end
      if !options[:only].blank?
        elements = elements.named(options[:only])
      elsif !options[:except].blank?
        elements = elements.excluded(options[:except])
      end
      elements = elements.reverse_order if options[:reverse_sort] || options[:reverse]
      elements = elements.offset(options[:offset]).limit(options[:count])
      elements = elements.order("RAND()") if options[:random]
      show_non_public ? elements : elements.published
    end

    # What is this? A Kind of proxy method? Why not rendering the elements directly if you already have them????
    def find_elements(options = {}, show_non_public = false)
      if !options[:collection].blank? && options[:collection].is_a?(Array)
        return options[:collection]
      else
        find_selected_elements(options, show_non_public)
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

  private

    # Looks in the page_layout descripion, if there are elements to autogenerate.
    #
    # And if so, it generates them.
    #
    # If the page has cells, it looks if there are elements to generate.
    #
    def autogenerate_elements
      elements_already_on_page = self.elements.available.collect(&:name)
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
      elements.select { |e| !definition['elements'].include?(e.name) }.map(&:trash)
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

  end
end
