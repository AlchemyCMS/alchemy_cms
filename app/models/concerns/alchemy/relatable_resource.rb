module Alchemy
  module RelatableResource
    extend ActiveSupport::Concern

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

      has_many :elements, through: :related_ingredients
      has_many :pages, through: :elements
    end

    # Returns true if object is not assigned to any ingredient.
    #
    def deletable?
      related_ingredients.none?
    end
  end
end
