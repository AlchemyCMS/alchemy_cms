module Alchemy
  class AttachmentsController < BaseController

    filter_access_to [:show, :download], :attribute_check => true, :model => Alchemy::Attachment, :load_method => :load_attachment

    # sends file inline. i.e. for viewing pdfs/movies in browser
    def show
      send_data(
        @attachment.file.data,
        {
          :filename => @attachment.file_name,
          :type => @attachment.file_mime_type,
          :disposition => 'inline'
        }
      )
    end

    # sends file as attachment. aka download
    def download
      send_data(
        @attachment.file.data, {
          :filename => @attachment.file_name,
          :type => @attachment.file_mime_type
        }
      )
    end

  private

    def load_attachment
      @attachment = Attachment.where(:id => params[:id]).first
    end

  end
end
