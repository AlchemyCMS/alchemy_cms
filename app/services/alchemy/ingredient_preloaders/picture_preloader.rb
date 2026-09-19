# frozen_string_literal: true

module Alchemy
  module IngredientPreloaders
    # Preloads associations on +Alchemy::Picture+ records that are the
    # +related_object+ of +Alchemy::Ingredients::Picture+ ingredients.
    #
    # Storage associations (one or two queries depending on adapter):
    #   ActiveStorage: image_file_attachment → blob
    #   Dragonfly:     thumbs
    #
    # Descriptions (one query):
    #   SELECT … FROM alchemy_picture_descriptions WHERE picture_id IN (…)
    #
    # Preloading +:descriptions+ ensures that +Picture#description_for(language)+
    # reads from the in-memory collection rather than issuing a +find_by+ per
    # picture, which would otherwise produce an N+1 query when rendering alt text.
    #
    # @example Wired in automatically via Alchemy.config.ingredient_preloaders
    class PicturePreloader
      # @param pictures [Array<Alchemy::Picture>]
      def self.call(pictures)
        return if pictures.blank?

        Alchemy.storage_adapter.preload_picture_associations(pictures)

        ActiveRecord::Associations::Preloader.new(
          records: pictures,
          associations: :descriptions
        ).call
      end
    end
  end
end
