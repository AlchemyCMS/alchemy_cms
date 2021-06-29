# frozen_string_literal: true

module Alchemy
  class Ingredient < BaseRecord
    class DefinitionError < StandardError; end

    include Hints

    self.abstract_class = true
    self.table_name = "alchemy_ingredients"

    belongs_to :element, touch: true, class_name: "Alchemy::Element", inverse_of: :ingredients
    belongs_to :related_object, polymorphic: true, optional: true

    validates :type, presence: true
    validates :role, presence: true

    validates_with Alchemy::IngredientValidator, on: :update, if: :has_validations?

    scope :audios, -> { where(type: "Alchemy::Ingredients::Audio") }
    scope :booleans, -> { where(type: "Alchemy::Ingredients::Boolean") }
    scope :datetimes, -> { where(type: "Alchemy::Ingredients::Datetime") }
    scope :files, -> { where(type: "Alchemy::Ingredients::File") }
    scope :headlines, -> { where(type: "Alchemy::Ingredients::Headline") }
    scope :htmls, -> { where(type: "Alchemy::Ingredients::Html") }
    scope :links, -> { where(type: "Alchemy::Ingredients::Link") }
    scope :nodes, -> { where(type: "Alchemy::Ingredients::Node") }
    scope :pages, -> { where(type: "Alchemy::Ingredients::Page") }
    scope :pictures, -> { where(type: "Alchemy::Ingredients::Picture") }
    scope :richtexts, -> { where(type: "Alchemy::Ingredients::Richtext") }
    scope :selects, -> { where(type: "Alchemy::Ingredients::Select") }
    scope :texts, -> { where(type: "Alchemy::Ingredients::Text") }
    scope :videos, -> { where(type: "Alchemy::Ingredients::Video") }

    class << self
      # Builds concrete ingredient class as described in the +elements.yml+
      def build(attributes = {})
        element = attributes[:element]
        raise ArgumentError, "No element given. Please pass element in attributes." if element.nil?
        raise ArgumentError, "No role given. Please pass role in attributes." if attributes[:role].nil?

        definition = element.ingredient_definition_for(attributes[:role])
        if definition.nil?
          raise DefinitionError,
            "No definition found for #{attributes[:role]}. Please define #{attributes[:role]} on #{element[:name]}."
        end

        ingredient_class = Ingredient.ingredient_class_by_type(definition[:type])
        ingredient_class.new(
          type: Ingredient.normalize_type(definition[:type]),
          value: default_value(definition),
          role: definition[:role],
          element: element,
        )
      end

      # Creates concrete ingredient class as described in the +elements.yml+
      def create(attributes = {})
        build(attributes).tap(&:save)
      end

      # Defines getter and setter method aliases for related object
      #
      # @param [String|Symbol] The name of the alias
      # @param [String] The class name of the related object
      def related_object_alias(name, class_name:)
        alias_method name, :related_object
        alias_method "#{name}=", :related_object=

        # Somehow Rails STI does not allow us to use `alias_method` for the related_object_id
        define_method "#{name}_id" do
          related_object_id
        end

        define_method "#{name}_id=" do |id|
          self.related_object_id = id
          self.related_object_type = class_name
        end
      end

      # Returns an ingredient class by type
      #
      # Raises ArgumentError if there is no such class in the
      # +Alchemy::Ingredients+ module namespace.
      #
      # If you add custom ingredient class,
      # put them in the +Alchemy::Ingredients+ module namespace
      #
      # @param [String] The ingredient class name to constantize
      # @return [Class]
      def ingredient_class_by_type(ingredient_type)
        Alchemy::Ingredients.const_get(ingredient_type.to_s.classify.demodulize)
      end

      # Modulize ingredient type
      #
      # Makes sure the passed ingredient type is in the +Alchemy::Ingredients+
      # module namespace.
      #
      # If you add custom ingredient class,
      # put them in the +Alchemy::Ingredients+ module namespace
      # @param [String] Ingredient class name
      # @return [String]
      def normalize_type(ingredient_type)
        "Alchemy::Ingredients::#{ingredient_type.to_s.classify.demodulize}"
      end

      def translated_label_for(role, element_name = nil)
        Alchemy.t(
          role,
          scope: "ingredient_roles.#{element_name}",
          default: Alchemy.t("ingredient_roles.#{role}", default: role.humanize),
        )
      end

      private

      # Returns the default value from ingredient definition
      #
      # If the value is a symbol it gets passed through i18n
      # inside the +alchemy.default_ingredient_texts+ scope
      def default_value(definition)
        default = definition[:default]
        case default
        when Symbol
          Alchemy.t(default, scope: :default_ingredient_texts)
        else
          default
        end
      end
    end

    # Compatibility method for access from element
    def essence
      self
    end

    # The value or the related object if present
    def value
      related_object || self[:value]
    end

    # Settings for this ingredient from the +elements.yml+ definition.
    def settings
      definition[:settings] || {}
    end

    # Fetches value from settings
    #
    # @param key [Symbol]               - The hash key you want to fetch the value from
    # @param options [Hash]             - An optional Hash that can override the settings.
    #                                     Normally passed as options hash into the content
    #                                     editor view.
    def settings_value(key, options = {})
      settings.merge(options || {})[key.to_sym]
    end

    # Definition hash for this ingredient from +elements.yml+ file.
    #
    def definition
      return {} unless element

      element.ingredient_definition_for(role) || {}
    end

    # The first 30 characters of the value
    #
    # Used by the Element#preview_text method.
    #
    # @param [Integer] max_length (30)
    #
    def preview_text(maxlength = 30)
      value.to_s[0..maxlength - 1]
    end

    # Cross DB adapter data accessor that works
    def data
      @_data ||= (self[:data] || {}).with_indifferent_access
    end

    # The path to the view partial of the ingredient
    # @return [String]
    def to_partial_path
      "alchemy/ingredients/#{partial_name}_view"
    end

    # The demodulized underscored class name of the ingredient
    # @return [String]
    def partial_name
      self.class.name.demodulize.underscore
    end

    # @return [Boolean]
    def has_validations?
      !!definition[:validate]
    end

    # @return [Boolean]
    def has_hint?
      !!definition[:hint]
    end

    # @return [Boolean]
    def deprecated?
      !!definition[:deprecated]
    end

    # @return [Boolean]
    def has_tinymce?
      false
    end

    private

    def hint_translation_attribute
      role
    end
  end
end
