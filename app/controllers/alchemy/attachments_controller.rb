# frozen_string_literal: true

module Alchemy
  class AttachmentsController < BaseController
    include ActiveStorage::Streaming

    before_action :load_attachment

    self.etag_with_template_digest = false

    # sends file inline. i.e. for viewing pdfs/movies in browser
    def show
      authorize! :show, @attachment
      send_blob disposition: :inline
    end

    # sends file as attachment. aka download
    def download
      authorize! :download, @attachment
      send_blob disposition: :attachment
    end

    private

    def load_attachment
      @attachment = Attachment.find(params[:id])
    end

    def send_blob(disposition: :inline)
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
