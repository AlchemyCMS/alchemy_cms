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

      # Renders a drag'n'drop picture gallery editor for element's gallery_pictures.
      #
      # It brings full functionality for adding images, deleting images and
      # sorting them via drag'n'drop.
      #
      # Just place this helper inside your element editor view,
      # pass the element as parameter and that's it.
      #
      # === Options:
      #
      #   :maximum_amount_of_images    [Integer]
      #     - This option let you handle the amount of images your customer can add to this element.
      #
      def render_picture_gallery_editor(element, options={})
        options = {maximum_amount_of_images: nil, grouped: true}.merge(options)
        render "alchemy/admin/elements/picture_gallery_editor", {
            pictures: element.contents.gallery_pictures,
            element: element,
            options: options
          }
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
        elements.collect do |element|
          render 'alchemy/admin/elements/refresh_editor', element: element
        end.join.html_safe
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
      # TODO: Is options[:draggable] still needed for trash window?

      # Tells us, if we should show the element footer.
      def show_element_footer?(element, with_nestable_elements = nil)
        return false if element.folded?
        if with_nestable_elements
          element.content_definitions.present? || element.taggable?
        else
          element.nestable_elements.empty?
        end
      end
    end
  end
end
