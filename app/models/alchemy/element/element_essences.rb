# frozen_string_literal: true

module Alchemy
  class Element < BaseRecord
    module ElementEssences
      # Returns the contents essence value (aka. ingredient) for passed content name.
      def ingredient(name)
        ing = ingredient_by_role(name)
        if ing
          Alchemy::Deprecation.warn(<<~WARN)
            Using `element.ingredient` to get the value of an ingredient is deprecated and will change in Alchemy 6.1
            If you want to read the value of an elements ingredient please use `element.value_for(:ingredient_role)` instead.
            The next version of Alchemy will return a `Alchemy::Ingredient` record instead.
          WARN
          ing.value
        else
          content = content_by_name(name)
          return nil if content.blank?

          content.ingredient
        end
      end

      # True if the element has a content for given name,
      # that has an essence value (aka. ingredient) that is not blank.
      # @deprecated
      def has_ingredient?(name)
        ingredient(name).present?
      end

      deprecate has_ingredient?: :has_value_for?, deprecator: Alchemy::Deprecation

      # Returns all essence errors in the format of:
      #
      #   {
      #     content.name => [
      #       error_message_for_validation_1,
      #       error_message_for_validation_2
      #     ]
      #   }
      #
      # Get translated error messages with +Element#essence_error_messages+
      #
      # @deprecated
      def essence_errors
        essence_errors = {}
        contents.each do |content|
          if content.essence_validation_failed?
            essence_errors[content.name] = content.essence.validation_errors
          end
        end
        essence_errors
      end

      deprecate :essence_errors, deprecator: Alchemy::Deprecation

      # Essence validation errors
      #
      # == Error messages are translated via I18n
      #
      # Inside your translation file add translations like:
      #
      #   alchemy:
      #     content_validations:
      #       name_of_the_element:
      #         name_of_the_content:
      #           validation_error_type: Error Message
      #
      # NOTE: +validation_error_type+ has to be one of:
      #
      #   * blank
      #   * taken
      #   * invalid
      #
      # === Example:
      #
      #   de:
      #     alchemy:
      #       content_validations:
      #         contactform:
      #           email:
      #             invalid: 'Die Email hat nicht das richtige Format'
      #
      #
      # == Error message translation fallbacks
      #
      # In order to not translate every single content for every element
      # you can provide default error messages per content name:
      #
      # === Example
      #
      #   en:
      #     alchemy:
      #       content_validations:
      #         fields:
      #           email:
      #             invalid: E-Mail has wrong format
      #             blank: E-Mail can't be blank
      #
      # And even further you can provide general field agnostic error messages:
      #
      # === Example
      #
      #   en:
      #     alchemy:
      #       content_validations:
      #         errors:
      #           invalid: %{field} has wrong format
      #           blank: %{field} can't be blank
      #
      # @deprecated
      def essence_error_messages
        messages = []
        essence_errors.each do |content_name, errors|
          errors.each do |error|
            messages << Alchemy.t(
              "#{name}.#{content_name}.#{error}",
              scope: "content_validations",
              default: [
                "fields.#{content_name}.#{error}".to_sym,
                "errors.#{error}".to_sym,
              ],
              field: Content.translated_label_for(content_name, name),
            )
          end
        end
        messages
      end

      deprecate essence_error_messages: :ingredient_error_messages, deprecator: Alchemy::Deprecation
    end
  end
end
