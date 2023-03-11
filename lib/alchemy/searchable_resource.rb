# frozen_string_literal: true

module Alchemy
  # Defines the methods that are needed to
  # make a model searchable in Alchemy's admin search by Ransack.
  module SearchableResource
    SEARCHABLE_COLUMN_TYPES = %i[string text]

    # Allow all string and text attributes to be searchable by Ransack.
    def ransackable_attributes(_auth_object = nil)
      searchable_alchemy_resource_attributes
    end

    # Allow all attributes to be sortable by Ransack.
    def ransortable_attributes(_auth_object = nil)
      columns.map(&:name)
    end

    # Allow all associations defined in +alchemy_resource_relations+ to be searchable by Ransack.
    def ransackable_associations(_auth_object = nil)
      searchable_alchemy_resource_associations
    end

    protected

    def searchable_alchemy_resource_attributes
      columns.select { |c| c.type.in?(SEARCHABLE_COLUMN_TYPES) }.map(&:name)
    end

    def searchable_alchemy_resource_associations
      if respond_to?(:alchemy_resource_relations)
        alchemy_resource_relations.keys.map!(&:to_s)
      else
        []
      end
    end
  end
end
