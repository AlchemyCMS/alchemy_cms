# frozen_string_literal: true

module Alchemy
  module IngredientPreloaders
    # Preloads storage associations on +Alchemy::Picture+ records that are the
    # +related_object+ of +Alchemy::Ingredients::Picture+ ingredients.
    #
    # Under ActiveStorage this fires two queries:
    #   SELECT … FROM active_storage_attachments WHERE … name = 'image_file' AND record_id IN (…)
    #   SELECT … FROM active_storage_blobs WHERE id IN (…)
    #
    # Under Dragonfly one query is fired:
    #   SELECT … FROM alchemy_picture_thumbs WHERE picture_id IN (…)
    #
    # @example Wired in automatically via Alchemy.config.ingredient_preloaders
    class PicturePreloader
      # @param pictures [Array<Alchemy::Picture>]
      def self.call(pictures)
        return if pictures.blank?

        Alchemy.storage_adapter.preload_picture_associations(pictures)
      end
    end
  end
end
