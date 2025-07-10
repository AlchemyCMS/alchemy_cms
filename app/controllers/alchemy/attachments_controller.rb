# frozen_string_literal: true

module Alchemy
  class AttachmentsController < BaseController
    if Alchemy.storage_adapter.active_storage?
      include ActiveStorage::Streaming
    end

    before_action :load_attachment
    authorize_resource class: Alchemy::Attachment

    self.etag_with_template_digest = false

    # sends file inline. i.e. for viewing pdfs/movies in browser
    def show
      if Alchemy.storage_adapter.dragonfly?
        send_attachment_file(disposition: :inline)
      else
        send_attachment_blob(disposition: :inline)
      end
    end

    # sends file as attachment. aka download
    def download
      if Alchemy.storage_adapter.dragonfly?
        send_attachment_file(disposition: :attachment)
      else
        send_attachment_blob(disposition: :attachment)
      end
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

    def send_attachment_blob(disposition: :inline)
      @blob = @attachment.file.blob

      if request.headers["Range"].present?
        send_blob_byte_range_data @blob, request.headers["Range"], disposition: disposition
      else
        http_cache_forever public: true do
          response.headers["Accept-Ranges"] = "bytes"
          send_blob_stream @blob, disposition: disposition
          # Rails ActionController::Live removes the Content-Length header,
          # but browsers need that to be able to show a progress bar during download.
          response.headers["Content-Length"] = @blob.byte_size.to_s
        end
      end
    end
  end
end
