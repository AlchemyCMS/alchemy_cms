# frozen_string_literal: true

module Alchemy
  class StorageAdapter
    # The class representing an URL to an Dragonfly attachment
    #
    class Dragonfly::AttachmentUrl
      attr_reader :attachment

      def initialize(attachment)
        @attachment = attachment
      end

      # The attachment url
      #
      # @param [Hash] options
      # @option options [Symbol] :download return a URL for downloading the attachment
      # @option options [Symbol] :name The filename
      # @option options [Symbol] :format The file extension
      #
      # @return [String]
      #
      def call(options = {})
        if attachment.file
          options[:format] ||= attachment.suffix
          if options.delete(:download)
            routes.download_attachment_path(attachment, options)
          else
            routes.show_attachment_path(attachment, options)
          end
        end
      end

      private

      def routes
        Alchemy::Engine.routes.url_helpers
      end
    end
  end
end
