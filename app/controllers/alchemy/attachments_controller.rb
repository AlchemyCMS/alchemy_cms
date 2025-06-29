# frozen_string_literal: true

module Alchemy
  class AttachmentsController < BaseController
    before_action :load_attachment
    authorize_resource class: Alchemy::Attachment

    # sends file inline. i.e. for viewing pdfs/movies in browser
    def show
      send_attachment_file(disposition: :inline)
    end

    # sends file as attachment. aka download
    def download
      send_attachment_file(disposition: :attachment)
    end

    private

    def load_attachment
      @attachment = Attachment.find(params[:id])
    end

    def send_attachment_file(disposition: :inline)
      response.headers["Content-Length"] = @attachment.file.size.to_s

      send_file(
        @attachment.file.path,
        {
          filename: @attachment.file_name,
          type: @attachment.file_mime_type,
          disposition: disposition
        }
      )
    end
  end
end
