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

      # Renders a drag'n'drop picture gallery editor for all EssencePictures.
      #
      # It brings full functionality for adding images, deleting images and sorting them via drag'n'drop.
      # Just place this helper inside your element editor view, pass the element as parameter and that's it.
      #
      # === Options:
      #
      #   :maximum_amount_of_images    [Integer]   # This option let you handle the amount of images your customer can add to this element.
      #
      def render_picture_gallery_editor(element, options = {})
        default_options = {
          maximum_amount_of_images: nil,
          grouped: true
        }
        options = default_options.merge(options)
        render(
          partial: "alchemy/admin/elements/picture_gallery_editor",
          locals: {
            pictures: element.contents.gallery_pictures,
            element: element,
            options: options
          }
        )
      end
      alias_method :render_picture_editor, :render_picture_gallery_editor

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
          options[optgroup_label] = cell_elements.map { |e|
            element_array_for_options(e, object_method, cell)
          }
        end
        options[_t(:main_content)] = elements_for_main_content(elements).map { |e|
          element_array_for_options(e, object_method)
        }
        options.delete_if { |_cell, elements| elements.blank? } # Throw out empty cells
      end

      def element_array_for_options(e, object_method, cell = nil)
        if e.class.name == 'Alchemy::Element'
          [
            e.display_name_with_preview_text,
            e.send(object_method).to_s + (cell ? "##{cell['name']}" : "")
          ]
        else
          [
            Element.display_name_for(e['name']),
            e[object_method] + (cell ? "##{cell['name']}" : "")
          ]
        end
      end

      # This helper loads all elements from page that have EssenceSelects in them.
      #
      # It returns a javascript function that replaces all editor partials of this elements.
      #
      # We need this while updating, creating or trashing an element,
      # because another element on the same page could have a element selector in it.
      #
      # In cases like this one wants Ember.js databinding!
      #
      def update_essence_select_elements(page, element)
        elements = page.elements.not_trashed.joins(:contents)
          .where(["#{Content.table_name}.element_id != ?", element.id])
          .where(Content.table_name => {essence_type: "Alchemy::EssenceSelect"})
        return if elements.blank?
        elements.collect { |element|
          render 'alchemy/admin/elements/refresh_editor', element: element
        }.join.html_safe
      end

      # CSS classes for the element editor partial.
      def element_editor_classes(element, local_assigns)
        [
          'element-editor',
          element.content_definitions.present? ? 'with-contents' : 'without-contents',
          element.nestable_elements.any? ? 'nestable' : 'not-nestable',
          element.taggable? ? 'taggable' : 'not-taggable',
          element.folded ? 'folded' : 'expanded',
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
