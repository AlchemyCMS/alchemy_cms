# frozen_string_literal: true

module Alchemy
  module Admin
    module EssencesHelper
      include Alchemy::EssencesHelper
      include Alchemy::Admin::ContentsHelper

      # Renders the Content editor partial from the given Content.
      # For options see -> render_essence
      # @deprecated
      def render_essence_editor(content, options = {}, html_options = {})
        if !options.empty?
          Alchemy::Deprecation.warn <<~WARN
            Passing options to `render_essence_editor` is deprecated and will be removed from Alchemy 5.0.
            Add your static `#{options.keys}` options to the `#{content.name}` content definitions `settings` of `#{content.element&.name}` element.
            For dynamic options consider adding your own essence class.
          WARN
        end
        if !html_options.empty?
          Alchemy::Deprecation.warn <<~WARN
            Passing html_options to `render_essence_editor` is deprecated and will be removed in Alchemy 5.0 without replacement.
          WARN
        end
        render_essence(content, :editor, {for_editor: options}, html_options)
      end
      deprecate :render_essence_editor, deprecator: Alchemy::Deprecation

      # Renders the Content editor partial found in views/contents/ for the content with name inside the passed Element.
      # For options see -> render_essence
      #
      # Content creation on the fly:
      #
      # If you update the elements.yml file after creating an element this helper displays a error message with an option to create the content.
      # @deprecated
      def render_essence_editor_by_name(element, name, options = {}, html_options = {})
        if element.blank?
          return warning('Element is nil', Alchemy.t(:no_element_given))
        end
        content = element.content_by_name(name)
        if content.nil?
          render_missing_content(element, name, options)
        else
          render_essence_editor(content, options, html_options)
        end
      end
      deprecate :render_essence_editor_by_name, deprecator: Alchemy::Deprecation

      # Returns all public pages from current language as an option tags string suitable or the Rails +select_tag+ helper.
      #
      # @param [Array]
      #   A collection of pages so it only returns these pages and does not query the database.
      # @param [String]
      #   Pass a +Page#name+ or +Page#id+ as selected item to the +options_for_select+ helper.
      # @param [String]
      #   Used as prompt message in the select tag
      # @param [Symbol]
      #   Method that is called on the page object to get the value that is passed with the params of the form.
      #
      def pages_for_select(pages = nil, selected = nil, prompt = "Choose page", page_attribute = :id)
        values = [[Alchemy.t(prompt), ""]]
        pages ||= begin
          nested = true
          Language.current.pages.published.order(:lft)
        end
        values += pages_attributes_for_select(pages, page_attribute, nested)
        options_for_select(values, selected.to_s)
      end

      # Renders the missing content partial
      # @deprecated
      def render_missing_content(element, name, options)
        render 'alchemy/admin/contents/missing', {element: element, name: name, options: options}
      end
      deprecate :render_missing_content, deprecator: Alchemy::Deprecation

      # Renders a thumbnail for given EssencePicture content with correct cropping and size
      def essence_picture_thumbnail(content)
        picture = content.ingredient
        essence = content.essence

        return if picture.nil?

        image_tag(
          essence.thumbnail_url,
          alt: picture.name,
          class: 'img_paddingtop',
          title: Alchemy.t(:image_name) + ": #{picture.name}"
        )
      end

      # Size value for edit picture dialog
      def edit_picture_dialog_size(content)
        if content.settings[:caption_as_textarea]
          content.settings[:sizes] ? '380x320' : '380x300'
        else
          content.settings[:sizes] ? '380x290' : '380x255'
        end
      end

      private

      # Returns an Array with page attributes for select options
      #
      # @param [Array]
      #   The pages
      # @param [String || Symbol]
      #   The attribute that is used as value
      # @param [Boolean] (false)
      #   Should the name be indented or not
      #
      def pages_attributes_for_select(pages, page_attribute, indent = false)
        pages.map do |page|
          [
            page_name_attribute_for_select(page, indent),
            page.send(page_attribute).to_s
          ]
        end
      end

      # Returns the page name for pages_for_select helper
      #
      # @param [Alchemy::Page]
      #   The page
      # @param [Boolean] (false)
      #   Should the page be indented or not
      #
      def page_name_attribute_for_select(page, indent = false)
        if indent
          ("&nbsp;&nbsp;" * (page.depth - 1) + page.name).html_safe
        else
          page.name
        end
      end
    end
  end
end
