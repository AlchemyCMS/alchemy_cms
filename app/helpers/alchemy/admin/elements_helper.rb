module Alchemy
  module Admin
    module ElementsHelper

      include Alchemy::ElementsHelper
      include Alchemy::ElementsBlockHelper
      include Alchemy::Admin::BaseHelper
      include Alchemy::Admin::ContentsHelper
      include Alchemy::Admin::EssencesHelper

      # Returns an Array for essence_text_editor select options_for_select.
      def elements_by_name_for_select(name, options={})
        defaults = {
          :grouped_by_page => true,
          :from_page => :all
        }
        options = defaults.merge(options)
        elements = all_elements_by_name(
          name,
          :from_page => options[:from_page]
        )
        if options[:grouped_by_page] && options[:from_page] == :all
          elements_for_options = {}
          pages = elements.collect(&:page).compact.uniq
          pages.sort { |x, y| x.name <=> y.name }.each do |page|
            page_elements = page.elements.select { |e| e.name == name }
            elements_for_options[page.name] = page_elements.map { |pe| [pe.preview_text, pe.id.to_s] }
          end
        else
          elements_for_options = elements.map { |e| [e.preview_text, e.id.to_s] }
          elements_for_options = [''] + elements_for_options
        end
        return elements_for_options
      end

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

      # Returns all elements that could be placed on that page because of the pages layout.
      # The elements are returned as an array to be used in alchemy_selectbox form builder.
      def elements_for_select(elements)
        return [] if elements.nil?
        options = elements.collect { |e| [t(e['name'], :scope => :element_names), e["name"]] }
        return options_for_select(options)
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
          optgroup_label = t(:main_content)
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
            Alchemy::I18n.t(e['name'], :scope => :element_names),
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
