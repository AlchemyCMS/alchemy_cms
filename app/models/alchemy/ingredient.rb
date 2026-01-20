# frozen_string_literal: true

module Alchemy
  class Ingredient < BaseRecord
    class DefinitionError < StandardError; end

    self.table_name = "alchemy_ingredients"

    attribute :data, :json

    belongs_to :element, touch: true, class_name: "Alchemy::Element", inverse_of: :ingredients
    belongs_to :related_object, polymorphic: true, optional: true

    has_one :page_version, through: :element, class_name: "Alchemy::PageVersion"
    has_one :page, through: :page_version, class_name: "Alchemy::Page"
    has_one :language, through: :page, class_name: "Alchemy::Language"

    after_initialize :set_default_value,
      if: -> { definition.default && value.nil? }

    validates :type, presence: true
    validates :role, presence: true, uniqueness: {scope: :element_id, case_sensitive: false}

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

    delegate :has_hint?, :hint, to: :definition

    class << self
      # Defines getter and setter method aliases for related object
      #
      # @param [String|Symbol] The name of the alias
      # @param [String] The class name of the related object
      def related_object_alias(name, class_name:)
        alias_method name, :related_object
        alias_method :"#{name}=", :related_object=

        # Somehow Rails STI does not allow us to use `alias_method` for the related_object_id
        define_method :"#{name}_id" do
          related_object_id
        end

        define_method :"#{name}_id=" do |id|
          self.related_object_id = id
          self.related_object_type = id.nil? ? nil : class_name
        end
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
          default: Alchemy.t("ingredient_roles.#{role}", default: role.humanize)
        )
      end

      # Allow to define settings on the ingredient definition
      def allow_settings(settings)
        @allowed_settings = Array(settings)
      end

      # Allowed settings on the ingredient
      def allowed_settings
        @allowed_settings ||= []
      end
    end

    # The value or the related object if present
    def value
      related_object || self[:value]
    end

    # Settings for this ingredient from the +elements.yml+ definition.
    def settings
      definition.settings
    end

    # Definition hash for this ingredient from +elements.yml+ file.
    #
    def definition
      return IngredientDefinition.new unless element

      element.ingredient_definition_for(role) || IngredientDefinition.new
    end

    # Returns the translated role for displaying in labels
    #
    # Translate it in your locale yml file:
    #
    #   alchemy:
    #     ingredient_roles:
    #       foo: Bar
    #
    # Optionally you can scope your ingredient role to an element:
    #
    #   alchemy:
    #     ingredient_roles:
    #       article:
    #         foo: Baz
    #
    def translated_role
      self.class.translated_label_for(role, element&.name)
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

    # The demodulized underscored class name of the ingredient
    # @return [String]
    def partial_name
      self.class.name.demodulize.underscore
    end

    # @return [Boolean]
    def has_validations?
      definition.validate.any?
    end

    # @return [Boolean]
    def deprecated?
      !!definition.deprecated
    end

    # @return [Boolean]
    def has_tinymce?
      false
    end

    def linked?
      link.try(:present?)
    end

    # @return [Boolean]
    def preview_ingredient?
      !!definition.as_element_title
    end

    # The view component of the ingredient with mapped options.
    #
    # @param options [Hash] - Passed to the view component as keyword arguments
    # @param html_options [Hash] - Passed to the view component
    def as_view_component(options: {}, html_options: {})
      view_component_class.new(self, **options, html_options: html_options)
    end

    # The editor component of the ingredient.
    #
    def as_editor_component
      editor_component_class.new(self)
    end

    private

    def view_component_class
      @_view_component_class ||= component_class_name(part: "View").constantize
    end

    def editor_component_class
      @_editor_component_class ||= component_class_name(part: "Editor").constantize
    end

    def component_class_name(part:)
      "#{self.class.name}#{part}"
    end

    def set_default_value
      self.value = definition.default_value
    end
  end
end
