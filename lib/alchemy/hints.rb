# frozen_string_literal: true

module Alchemy
  module Hints
    # Returns a hint
    #
    # To add a hint to a content pass +hint: true+ to the element definition in its element.yml
    #
    # Then the hint itself is placed in the locale yml files.
    #
    # Alternativly you can pass the hint itself to the hint key.
    #
    # == Locale Example:
    #
    #   # elements.yml
    #   - name: headline
    #     contents:
    #     - name: headline
    #       type: EssenceText
    #       hint: true
    #
    #   # config/locales/de.yml
    #     de:
    #       content_hints:
    #         headline: Lorem ipsum
    #
    # == Hint Key Example:
    #
    #   - name: headline
    #     contents:
    #     - name: headline
    #       type: EssenceText
    #       hint: Lorem ipsum
    #
    # @return String
    #
    def hint
      hint = definition[:hint]
      if hint == true
        Alchemy.t(hint_translation_attribute, scope: hint_translation_scope)
      else
        hint
      end
    end

    # Returns true if the element has a hint defined
    def has_hint?
      !!definition[:hint]
    end

    private

    def hint_translation_attribute
      name
    end

    def hint_translation_scope
      "#{self.class.model_name.to_s.demodulize.downcase}_hints"
    end
  end
end
