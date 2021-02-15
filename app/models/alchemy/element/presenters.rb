# frozen_string_literal: true

module Alchemy
  class Element < BaseRecord
    # Methods used for presenting an Alchemy Element.
    #
    module Presenters
      extend ActiveSupport::Concern

      module ClassMethods
        # Human name for displaying elements in select boxes and element editor views.
        #
        # The name is beeing translated from given name value as described in +config/alchemy/elements.yml+
        #
        # Translate the name in your +config/locales+ language file.
        #
        # == Example:
        #
        #   de:
        #     alchemy:
        #       element_names:
        #         contactform: 'Kontakt Formular'
        #
        # If no translation is found a humanized name is used.
        #
        def display_name_for(name)
          Alchemy.t(name, scope: "element_names", default: name.to_s.humanize)
        end
      end

      # Returns the translated name
      #
      # @see Alchemy::Element::Presenters#display_name_for
      #
      def display_name
        self.class.display_name_for(definition["name"] || name)
      end

      # Returns a preview text for element.
      #
      # It's taken from the first Content found in the +elements.yml+ definition file.
      #
      # You can flag a Content as +as_element_title+ to take this as preview.
      #
      # @param maxlength [Fixnum] (60)
      #   Length of characters after the text will be cut off.
      #
      def preview_text(maxlength = 60)
        preview_text_from_preview_content(maxlength) || preview_text_from_nested_elements(maxlength)
      end

      # Generates a preview text containing Element#display_name and Element#preview_text.
      #
      # It is displayed inside the head of the Element in the Elements.list overlay window from the Alchemy Admin::Page#edit view.
      #
      # === Example
      #
      # A Element described as:
      #
      #     - name: funky_element
      #       display_name: Funky Element
      #       contents:
      #       - name: headline
      #         type: EssenceText
      #       - name: text
      #         type EssenceRichtext
      #         as_element_title: true
      #
      # With "I want to tell you a funky story" as stripped_body for the EssenceRichtext Content produces:
      #
      #     Funky Element: I want to tell ...
      #
      # @param maxlength [Fixnum] (30)
      #   Length of characters after the text will be cut off.
      #
      def display_name_with_preview_text(maxlength = 30)
        "#{display_name}: #{preview_text(maxlength)}"
      end

      # Returns a dom id used for elements html id tag.
      #
      def dom_id
        "#{name}_#{id}"
      end

      # The content that's used for element's preview text.
      #
      # It tries to find one of element's contents that is defined +as_element_title+.
      # Takes element's first content if no content is defined +as_element_title+.
      #
      # @return (Alchemy::Content)
      #
      def preview_content
        @_preview_content ||= contents.detect(&:preview_content?) || contents.first
      end

      private

      def preview_text_from_nested_elements(maxlength)
        return if all_nested_elements.empty?

        all_nested_elements.first.preview_text(maxlength)
      end

      def preview_text_from_preview_content(maxlength)
        preview_content.try!(:preview_text, maxlength)
      end
    end
  end
end
