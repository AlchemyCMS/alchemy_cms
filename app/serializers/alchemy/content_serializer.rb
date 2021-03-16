# frozen_string_literal: true

module Alchemy
  class ContentSerializer < ActiveModel::Serializer
    attributes :id,
      :name,
      :ingredient,
      :element_id,
      :settings

    with_options if: :can_read? do
      attribute :label
      attribute :component_name
      attribute :form_field_id
      attribute :form_field_name
      attribute :validations
      attribute :validation_errors
    end

    has_one :essence, polymorphic: false

    def ingredient
      object.serialized_ingredient
    end

    def component_name
      object.essence_type.underscore.dasherize.parameterize
    end

    def label
      object.name_for_label
    end

    def form_field_id
      Alchemy::ContentEditor.new(object).form_field_id
    end

    def form_field_name
      Alchemy::ContentEditor.new(object).form_field_name
    end

    def validations
      object.definition["validate"] || []
    end

    def validation_errors
      object.essence_validation_error_messages
    end

    def can_read?
      scope.can?(:read, object)
    end
  end
end
