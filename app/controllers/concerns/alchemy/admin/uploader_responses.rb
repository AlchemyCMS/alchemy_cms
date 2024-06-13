# frozen_string_literal: true

module Alchemy
  module Admin
    module UploaderResponses
      extend ActiveSupport::Concern

      def successful_uploader_response(file:, status: :created)
        message = Alchemy.t(:upload_success,
          scope: [:uploader, file.class.model_name.i18n_key],
          name: file.name)

        {
          json: {message: message},
          status: status
        }
      end

      def failed_uploader_response(file:)
        message = Alchemy.t(:upload_failure,
          scope: [:uploader, file.class.model_name.i18n_key],
          error: file.errors[:file].join,
          name: file.name)

        {
          json: {message: message},
          status: :unprocessable_entity
        }
      end
    end
  end
end
