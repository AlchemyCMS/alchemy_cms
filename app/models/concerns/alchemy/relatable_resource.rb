module Alchemy
  module RelatableResource
    extend ActiveSupport::Concern

    class_methods do
      # Preload associations for element editor display
      #
      # Override this method in models that need custom preloading
      # when displayed in the element editor (e.g., preloading
      # language-specific descriptions).
      #
      # @param records [Array] Collection of records to preload for
      # @param language [Alchemy::Language] Current language context
      def alchemy_element_preloads(records, language:)
        # Default implementation does nothing
        # Override in subclasses that need preloading
      end
    end

    included do
      scope :deletable, -> do
        where(
          "#{table_name}.id NOT IN (SELECT related_object_id FROM alchemy_ingredients WHERE related_object_id IS NOT NULL AND related_object_type = ?)",
          name
        )
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
