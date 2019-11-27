# frozen_string_literal: true

module Alchemy
  module Admin
    module EssencesHelper
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
      # @deprecated
      def pages_for_select(pages = nil, selected = nil, prompt = "Choose page", page_attribute = :id)
        values = [[Alchemy.t(prompt), ""]]
        pages ||= begin
          nested = true
          Language.current.pages.published.order(:lft)
        end
        values += pages_attributes_for_select(pages, page_attribute, nested)
        options_for_select(values, selected.to_s)
      end
      deprecate :pages_for_select, deprecator: Alchemy::Deprecation

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
      deprecate :pages_attributes_for_select, deprecator: Alchemy::Deprecation

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
      deprecate :page_name_attribute_for_select, deprecator: Alchemy::Deprecation
    end
  end
end
