module Alchemy
  class AttachmentsController < BaseController
    before_action :load_attachment
    authorize_resource class: Alchemy::Attachment

    # sends file inline. i.e. for viewing pdfs/movies in browser
    def show
      send_data(
        @attachment.file.data,
        {
          filename: @attachment.file_name,
          type: @attachment.file_mime_type,
          disposition: 'inline'
        }
      )
    end

    # sends file as attachment. aka download
    def download
      send_data(
        @attachment.file.data, {
          filename: @attachment.file_name,
          type: @attachment.file_mime_type
        }
      )
    end

    private

    def load_attachment
      @attachment = Attachment.find(params[:id])
    end

  end
end
