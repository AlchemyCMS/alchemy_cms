# frozen_string_literal: true

module Alchemy
  class IngredientDefinition
    include ActiveModel::Model
    include ActiveModel::Attributes
    include Alchemy::Hints

    extend ActiveModel::Translation

    attribute :role, :string
    attribute :type, :string
    attribute :as_element_title, :boolean, default: false
    attribute :settings, default: {}
    attribute :validate, default: []
    attribute :group, :string
    attribute :default
    attribute :deprecated
    attribute :hint

    validates :role,
      presence: true,
      format: {
        with: /\A[a-z_-]+\z/
      }

    validates :type,
      presence: true,
      format: {
        with: /\A[A-Z][a-zA-Z]+\z/
      }

    delegate :blank?, to: :role

    def attributes
      super.with_indifferent_access
    end

    def settings
      super.with_indifferent_access
    end

    def validate
      super.map do |validation|
        case validation
        when Hash
          validation.with_indifferent_access
        else
          validation
        end
      end
    end

    # Returns the default value from ingredient definition
    #
    # If the value is a symbol it gets passed through i18n
    # inside the +alchemy.default_ingredient_texts+ scope
    def default_value
      case default
      when Symbol
        Alchemy.t(default, scope: :default_ingredient_texts)
      when String
        default
      end
    end

    # Returns a deprecation notice for ingredients marked deprecated
    #
    # You can either use localizations or pass a String as notice
    # in the ingredient definition.
    #
    # == Custom deprecation notices
    #
    # Use general ingredient deprecation notice
    #
    #     - name: element_name
    #       ingredients:
    #         - role: old_ingredient
    #           type: Text
    #           deprecated: true
    #
    # Add a translation to your locale file for a per ingredient notice.
    #
    #     en:
    #       alchemy:
    #         ingredient_deprecation_notices:
    #           old_ingredient: Foo baz widget is deprecated
    #
    # You can scope the translation per element as well.
    #
    #     en:
    #       alchemy:
    #         ingredient_deprecation_notices:
    #           element_name:
    #             old_ingredient: Elements foo baz widget is deprecated
    #
    # or use the global translation that apply to all deprecated ingredients.
    #
    #     en:
    #       alchemy:
    #         ingredient_deprecation_notice: Foo baz widget is deprecated
    #
    # or pass string as deprecation notice.
    #
    #     - name: element_name
    #       ingredients:
    #         - role: old_ingredient
    #           type: Text
    #           deprecated: This ingredient will be removed soon.
    #
    def deprecation_notice(element_name: nil)
      case deprecated
      when String
        deprecated
      when TrueClass
        Alchemy.t(
          role,
          scope: [:ingredient_deprecation_notices, element_name].compact,
          default: Alchemy.t(:ingredient_deprecated)
        )
      end
    end

    private

    def hint_translation_scope
      :ingredient_hints
    end

    def hint_translation_attribute
      role
    end
  end
end
