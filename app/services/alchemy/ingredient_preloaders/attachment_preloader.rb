# frozen_string_literal: true

module Alchemy
  module IngredientPreloaders
    # Preloads storage associations on +Alchemy::Attachment+ records that are the
    # +related_object+ of +Alchemy::Ingredients::File+, +Alchemy::Ingredients::Audio+,
    # and +Alchemy::Ingredients::Video+ ingredients.
    #
    # Under ActiveStorage this fires two queries:
    #   SELECT … FROM active_storage_attachments WHERE … name = 'file' AND record_id IN (…)
    #   SELECT … FROM active_storage_blobs WHERE id IN (…)
    #
    # This eliminates N+1 queries when rendering attributes like +file_mime_type+,
    # +file_name+, +file_size+, and +extension+ / +suffix+, all of which read
    # through the ActiveStorage +file+ attachment to its blob.
    #
    # Under Dragonfly all attachment metadata is stored directly in database
    # columns, so this is a no-op.
    #
    # @example Wired in automatically via Alchemy.config.ingredient_preloaders
    class AttachmentPreloader
      # @param attachments [Array<Alchemy::Attachment>]
      def self.call(attachments)
        return if attachments.blank?

        Alchemy.storage_adapter.preload_attachment_associations(attachments)
      end
    end
  end
end
