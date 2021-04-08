# frozen_string_literal: true

module Alchemy
  class Ingredient < BaseRecord
    class DefinitionError < StandardError; end

    self.abstract_class = true
    self.table_name = "alchemy_ingredients"

    belongs_to :element, class_name: "Alchemy::Element"
    belongs_to :related_object, polymorphic: true, optional: true

    validates :type, presence: true
    validates :role, presence: true

    class << self
      # Defines getters and setter methods for ingredient attributes
      def ingredient_attributes(*attributes)
        attributes.each do |name|
          define_method name.to_sym do
            data[name]
          end
          define_method "#{name}=" do |value|
            data[name] = value
          end
        end
      end

      # Defines getter and setter method aliases for related object
      def related_object_alias(name)
        alias_method name, :related_object
        alias_method "#{name}=", :related_object=
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

    # Definition hash for this ingredient from +elements.yml+ file.
    #
    def definition
      return {} unless element

      element.content_definition_for(role) || {}
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
  end
end
