module Alchemy
  module Admin
    class AttachmentSelect < ViewComponent::Base
      delegate :alchemy, to: :helpers

      def initialize(attachment = nil, url: nil, placeholder: Alchemy.t("Please choose"), query_params: nil)
        @attachment = attachment
        @url = url
        @placeholder = placeholder
        @query_params = query_params
      end

      def call
        content_tag("alchemy-attachment-select", content, attributes)
      end

      private

      def attributes
        options = {
          "allow-clear": true,
          placeholder: @placeholder,
          url: @url || alchemy.api_attachments_path
        }

        if @query_params
          options[:"query-params"] = @query_params.to_json
        end

        if @attachment
          selection = ActiveModelSerializers::SerializableResource.new(@attachment)
          options[:selection] = selection.to_json
        end

        options
      end
    end
  end
end
