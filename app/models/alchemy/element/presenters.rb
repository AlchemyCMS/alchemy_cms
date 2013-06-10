module Alchemy

  # Methods used for presenting an Alchemy Element.
  #
  module Element::Presenters
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
        I18n.t(name, scope: 'element_names', default: name.to_s.humanize)
      end
    end

    # Returns the translated name
    #
    # @see Alchemy::Element::Presenters#display_name_for
    #
    def display_name
      self.class.display_name_for(description['name'] || self.name)
    end

    # Returns a preview text for element.
    #
    # It's taken from the first Content found in the +elements.yml+ description file.
    #
    # You can flag a Content as +take_me_for_preview+ to take this as preview.
    #
    # @param maxlength [Fixnum] (30)
    #   Length of characters after the text will be cut off.
    #
    def preview_text(maxlength = 30)
      (contents.detect(&:preview_content?) || contents.first).try(:preview_text, maxlength)
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
    #         take_me_for_preview: true
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

  end

end
