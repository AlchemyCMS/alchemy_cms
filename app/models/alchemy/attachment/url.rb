# frozen_string_literal: true

module Alchemy
  class Attachment < BaseRecord
    # The class representing an URL to an attachment
    #
    # Set a different one
    #
    #     Alchemy::Attachment.url_class = MyRemoteUrlClass
    #
    class Url
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
        if options.delete(:download)
          routes.download_attachment_path(@attachment, options)
        else
          routes.show_attachment_path(@attachment, options)
        end
      end

      private

      def routes
        Alchemy::Engine.routes.url_helpers
      end
    end
  end
end
