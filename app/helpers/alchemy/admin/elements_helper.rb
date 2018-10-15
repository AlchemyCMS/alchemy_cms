# frozen_string_literal: true

module Alchemy
  module Admin
    module ElementsHelper
      include Alchemy::ElementsHelper
      include Alchemy::ElementsBlockHelper
      include Alchemy::Admin::BaseHelper
      include Alchemy::Admin::ContentsHelper
      include Alchemy::Admin::EssencesHelper

      # Renders the element editor partial
      def render_editor(element)
        render_element(element, :editor)
      end

      # Returns an elements array for select helper.
      #
      # @param [Array] elements definitions
      # @return [Array]
      #
      def elements_for_select(elements)
        return [] if elements.nil?
        elements.collect do |e|
          [
            Element.display_name_for(e['name']),
            e['name']
          ]
        end
      end

      # Returns all elements that can be placed on the current page.
      # The elements will be grouped by cell.
      #
      # @param [Array] elements
      #   collection of element objects
      # @param [String] object_method
      #   method that is called on the element objects used for the select option value
      #
      def grouped_elements_for_select(elements, object_method = 'name')
        return [] if elements.blank?
        cells_definition = @page.cell_definitions
        return [] if cells_definition.blank?
        options = {}
        cells_definition.each do |cell|
          cell_elements = elements_for_cell(elements, cell)
          optgroup_label = Cell.translated_label_for(cell['name'])
          options[optgroup_label] = cell_elements.map do |e|
            element_array_for_options(e, object_method, cell)
          end
        end
        options[Alchemy.t(:main_content)] = elements_for_main_content(elements).map do |e|
          element_array_for_options(e, object_method)
        end
        # Remove empty cells
        options.delete_if { |_c, e| e.blank? }
      end

      def element_array_for_options(element, object_method, cell = nil)
        case element
        when Alchemy::Element
          [
            element.display_name_with_preview_text,
            element.send(object_method).to_s + (cell ? "##{cell['name']}" : "")
          ]
        else
          [
            Element.display_name_for(element['name']),
            element[object_method] + (cell ? "##{cell['name']}" : "")
          ]
        end
      end

      # CSS classes for the element editor partial.
      def element_editor_classes(element, local_assigns)
        [
          'element-editor',
          element.content_definitions.present? ? 'with-contents' : 'without-contents',
          element.nestable_elements.any? ? 'nestable' : 'not-nestable',
          element.taggable? ? 'taggable' : 'not-taggable',
          element.folded ? 'folded' : 'expanded',
          element.compact? ? 'compact' : nil,
          local_assigns[:draggable] == false ? 'not-draggable' : 'draggable'
        ].join(' ')
      end

      # Tells us, if we should show the element footer.
      def show_element_footer?(element, with_nestable_elements = nil)
        return false if element.folded?
        if with_nestable_elements
          element.content_definitions.present? || element.taggable?
        else
          element.nestable_elements.empty?
        end
      end

      private

      def elements_for_main_content(elements)
        page_definition = @page.definition['elements']
        elements.select do |e|
          page_definition.include?(e.class.name == 'Element' ? e.name : e['name'])
        end
      end

      def elements_for_cell(elements, cell)
        cell_elements = cell['elements']
        elements.select do |e|
          cell_elements.include?(e.class.name == 'Element' ? e.name : e['name'])
        end
      end
    end
  end
end
