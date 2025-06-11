# frozen_string_literal: true

module Alchemy
  module Hints
    # Returns a hint
    #
    # To add a hint to a ingredient pass +hint: true+ to the element definition in its element.yml
    #
    # Then the hint itself is placed in the locale yml files.
    #
    # Alternativly you can pass the hint itself to the hint key.
    #
    # == Locale Example:
    #
    #   # elements.yml
    #   - name: headline
    #     ingredients:
    #       - role: headline
    #         type: Text
    #         hint: true
    #
    #   # config/locales/de.yml
    #     de:
    #       ingredient_hints:
    #         headline: Lorem ipsum
    #
    # == Hint Key Example:
    #
    #   - name: headline
    #     ingredients:
    #       - role: headline
    #         type: Text
    #         hint: Lorem ipsum
    #
    # @return String
    #
    def hint
      hint = attributes[:hint]
      if hint == true
        Alchemy.t(hint_translation_attribute, scope: hint_translation_scope)
      else
        hint
      end
    end

    # Returns true if the definition has a hint defined
    def has_hint?
      !!attributes[:hint]
    end

    private

    def hint_translation_attribute
      name
    end
  end
end
