# frozen_string_literal: true

module Alchemy
  module Admin
    module ElementsHelper
      include Alchemy::ElementsBlockHelper
      include Alchemy::Admin::BaseHelper
      include Alchemy::Admin::ContentsHelper
      include Alchemy::Admin::EssencesHelper

      # Renders a {Alchemy::Element} editor partial.
      #
      # A element editor partial is the form presented to the content author in page edit mode.
      #
      # The partial is located in <tt>app/views/alchemy/elements</tt>.
      #
      # == Partial naming
      #
      # The partials have to be named after the name of the element as defined in the <tt>elements.yml</tt> file and has to be suffixed with <tt>_editor</tt>.
      #
      # === Example
      #
      # Given a headline element
      #
      #   # elements.yml
      #   - name: headline
      #     contents:
      #     - name: text
      #       type: EssenceText
      #
      # Then your element editor partial has to be named:
      #
      #   app/views/alchemy/elements/_headline_editor.html.{erb|haml|slim}
      #
      # === Element partials generator
      #
      # You can use this handy generator to let Alchemy generate the partials for you:
      #
      #   $ rails generate alchemy:elements --skip
      #
      # == Usage
      #
      #   <%= render_editor(Alchemy::Element.published.named(:headline).first) %>
      #
      # @param [Alchemy::Element] element
      #   The element you want to render the editor for
      #
      # @note If the partial is not found
      #   <tt>alchemy/elements/_editor_not_found.html.erb</tt> gets rendered.
      #
      def render_editor(element)
        if element.nil?
          warning('Element is nil')
          render "alchemy/elements/editor_not_found", {name: 'nil'}
          return
        end

        render "alchemy/elements/#{element.name}_editor", element: element
      rescue ActionView::MissingTemplate => e
        warning(%(
          Element editor partial not found for #{element.name}.\n
          #{e}
        ))
        render "alchemy/elements/editor_not_found", {
          name: element.name,
          error: "Element editor partial not found.<br>Use <code>rails generate alchemy:elements</code> to generate it."
        }
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

      # CSS classes for the element editor partial.
      def element_editor_classes(element)
        [
          'element-editor',
          element.content_definitions.present? ? 'with-contents' : 'without-contents',
          element.nestable_elements.any? ? 'nestable' : 'not-nestable',
          element.taggable? ? 'taggable' : 'not-taggable',
          element.folded ? 'folded' : 'expanded',
          element.compact? ? 'compact' : nil,
          element.fixed? ? 'is-fixed' : 'not-fixed'
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
    end
  end
end
