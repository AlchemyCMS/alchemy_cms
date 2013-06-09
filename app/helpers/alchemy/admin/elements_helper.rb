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
      def render_picture_gallery_editor(element, options={})
        default_options = {
          :maximum_amount_of_images => nil,
          :grouped => true
        }
        options = default_options.merge(options)
        render(
          :partial => "alchemy/admin/elements/picture_gallery_editor",
          :locals => {
            :pictures => element.contents.gallery_pictures,
            :element => element,
            :options => options
          }
        )
      end
      alias_method :render_picture_editor, :render_picture_gallery_editor

      # Returns a elements options string for select helper.
      #
      # @param [Array] elements descriptions
      # @return [String]
      #
      def elements_for_select(elements)
        return [] if elements.nil?
        options = elements.collect do |e|
          [
            Element.display_name_for(e['name']),
            e['name']
          ]
        end
        options_for_select(options)
      end

      # Returns all elements that could be placed on that page because of the pages layout.
      # The elements will be grouped by cell.
      def grouped_elements_for_select(elements, object_method = 'name')
        return "" if elements.blank?
        cells_definition = @page.cell_definitions
        return "" if cells_definition.blank?
        options = {}
        celled_elements = []
        cells_definition.each do |cell|
          cell_elements = elements.select { |e| cell['elements'].include?(e.class.name == 'Element' ? e.name : e['name']) }
          celled_elements += cell_elements
          optgroup_label = Cell.translated_label_for(cell['name'])
          options[optgroup_label] = cell_elements.map do |e|
            element_array_for_options(e, object_method, cell)
          end
        end
        other_elements = elements - celled_elements
        unless other_elements.blank?
          optgroup_label = _t(:main_content)
          options[optgroup_label] = other_elements.map do |e|
            element_array_for_options(e, object_method)
          end
        end
        return grouped_options_for_select(options)
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

      def update_elements_with_essence_selects(page, element)
        elements = page.contents.essence_selects.collect(&:element).uniq.delete_if { |e| e == element }
        if elements.any?
          js = "var $ess_sel_el;"
          elements.each do |element|
            rtfs = element.contents.essence_richtexts
            js += "\n$ess_sel_el = $('#element_#{element.id}');"
            rtfs.each do |content|
              js += "\ntinymce.get('contents_content_#{content.id}_body').remove();"
            end
            js += "\n$('div.element_content', $ess_sel_el).html('#{escape_javascript render_editor(element)}');"
            js += "\nAlchemy.GUI.initElement($ess_sel_el);"
            rtfs.each do |content|
              js += "\nAlchemy.Tinymce.addEditor('#{content.form_field_id}');"
            end
          end
          js
        else
          nil
        end
      end

    end
  end
end
