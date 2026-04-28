module Alchemy
  module RelatableResource
    extend ActiveSupport::Concern

    # SQL subquery selecting +related_object_id+ values for ingredients that
    # reference a given polymorphic type. Intended to be composed into a
    # +NOT IN (...)+ clause by +deletable+ and any overrides in including
    # classes. Takes one named bind :type - the polymorphic type name,
    # typically the class name of the including model
    # (e.g. +"Alchemy::Attachment"+).
    RELATED_INGREDIENTS_SUBQUERY = <<~SQL.squish
      SELECT related_object_id
      FROM alchemy_ingredients
      WHERE related_object_id IS NOT NULL
        AND related_object_type = :type
    SQL

    class_methods do
      # Preload associations for element editor display
      #
      # Override this method in models that need custom preloading
      # when displayed in the element editor (e.g., preloading
      # picture thumbnails or products).
      #
      # @param records [Array] Collection of records to preload for
      def alchemy_element_preloads(records)
        # Default implementation does nothing
        # Override in subclasses that need preloading
      end
    end

    included do
      scope :deletable, -> do
        where("#{table_name}.id NOT IN (#{RELATED_INGREDIENTS_SUBQUERY})", type: name)
      end

      has_many :related_ingredients,
        class_name: "Alchemy::Ingredient",
        foreign_key: "related_object_id",
        as: :related_object

      has_many :related_elements, through: :related_ingredients, source: :element
      has_many :related_pages, through: :related_elements, source: :page
    end

    # Returns true if object is not assigned to any ingredient.
    #
    def deletable?
      related_ingredients.none?
    end
  end
end
