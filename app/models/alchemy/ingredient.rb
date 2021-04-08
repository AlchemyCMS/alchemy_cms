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

    # Defines getters and setter methods for ingredient attributes
    def self.ingredient_attributes(*attributes)
      attributes.each do |name|
        define_method name.to_sym do
          data[name]
        end
        define_method "#{name}=" do |value|
          data[name] = value
        end
      end
    end

    # Compatibility method for access from element
    def essence
      self
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

    # Cross DB adapter data accessor that works
    def data
      @_data ||= (self[:data] || {}).with_indifferent_access
    end
  end
end
